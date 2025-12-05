package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"os"
	"path"
	"sort"
	"strings"

	"github.com/go-git/go-git/v6"
	"github.com/go-git/go-git/v6/plumbing"
)

const (
	VimPlugLock = ".vim-plug.lock"
	VimPlugFile = ".vim-plug.json"

	GithubHost     = "https://github.com"
	GithubTemplate = "https://github.com/%s.git"

	DefaultVimHome     = ".config/nvim"
	DefaultPluginsHome = ".local/share/nvim/site/pack/plugins/start"
)

type VimPlugConfig struct {
	Plugins []Plugin `json:"plugins"`
}

type Plugin struct {
	Name   string `json:"name"`
	URL    string `json:"url"`
	Branch string `json:"branch"`
}

func (p Plugin) GetName() string {
	name := p.Name
	if p.Name == "" {
		parts := strings.Split(strings.TrimSuffix(p.URL, "/"), "/")
		if len(parts) >= 2 {
			name = parts[len(parts)-2] + "/" + parts[len(parts)-1]
		} else {
			name = p.URL
		}
	}

	return strings.TrimSuffix(name, ".git")
}

func (p Plugin) DirectoryName() string {
	lastIdx := strings.LastIndex(p.GetName(), "/")
	if lastIdx == -1 {
		return p.GetName()
	}

	return p.GetName()[lastIdx+1:]
}

func (p Plugin) GetURL() string {
	if p.URL == "" {
		return fmt.Sprintf(GithubTemplate, p.GetName())
	}

	return p.URL
}

type Lockfile struct {
	Plugins []LokedPlugin `json:"plugins"`
}

type LokedPlugin struct {
	Name   string `json:"name"`
	URL    string `json:"url"`
	Commit string `json:"commit"`
}

type Config struct {
	VimHome     string
	PluginsHome string
}

func main() {
	home, _ := os.UserHomeDir()
	c := Config{
		VimHome:     path.Join(home, DefaultVimHome),
		PluginsHome: path.Join(home, DefaultPluginsHome),
	}

	if home := os.Getenv("NEOVIM_HOME"); home != "" {
		c.VimHome = home
	}

	if home := os.Getenv("NEOVIM_PLUGINS_HOME"); home != "" {
		c.PluginsHome = home
	}

	if err := Sync(c); err != nil {
		log.Fatal("cannot sync plugins: ", err)
	}
}

func Sync(config Config) error {
	pluginsFilePath := path.Join(config.VimHome, VimPlugFile)

	var plugins VimPlugConfig
	log.Println("loading plugins from", pluginsFilePath)
	if err := loadJSON(pluginsFilePath, &plugins); err != nil {
		return err
	}

	lockFilePath := path.Join(config.VimHome, VimPlugLock)
	log.Println("loading lockfile from", lockFilePath)
	var lockfile Lockfile
	if err := loadJSON(lockFilePath, &lockfile); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}

	if lockfile.Plugins == nil {
		log.Println("lockfile is empty")
	} else {
		log.Println("lockfile has", len(lockfile.Plugins), "plugins")
	}

	pluginsMap := make(map[string]Plugin)
	for _, p := range plugins.Plugins {
		pluginsMap[p.Name] = p
	}

	lockedMap := make(map[string]LokedPlugin)
	for _, p := range lockfile.Plugins {
		lockedMap[p.Name] = p
	}

	pluginsToInstall := []Plugin{}
	pluginsToUpdate := []Plugin{}
	for name, plugin := range pluginsMap {
		if _, ok := lockedMap[name]; !ok {
			pluginsToInstall = append(pluginsToInstall, plugin)
			continue
		}

		if lockedMap[name].Commit != plugin.Branch {
			pluginsToUpdate = append(pluginsToUpdate, plugin)
		}
	}

	pluginsToUninstall := []Plugin{}
	for name := range lockedMap {
		if plugin, ok := pluginsMap[name]; !ok {
			pluginsToUninstall = append(pluginsToUninstall, plugin)
		}
	}

	if err := Uninstall(config, pluginsToUninstall); err != nil {
		return err
	}

	var newLockfile Lockfile
	if err := InstallPlugins(config, pluginsToInstall, &newLockfile); err != nil {
		return err
	}

	if err := UpdatePlugins(config, pluginsToUpdate, &newLockfile); err != nil {
		return err
	}

	// sort the plugins
	sort.Slice(newLockfile.Plugins, func(i, j int) bool {
		return newLockfile.Plugins[i].Name < newLockfile.Plugins[j].Name
	})

	log.Println("saving lockfile to", lockFilePath)
	if err := saveJSON(lockFilePath, newLockfile); err != nil {
		return fmt.Errorf("cannot save lockfile: %w", err)
	}

	return nil
}

func InstallPlugins(config Config, plugins []Plugin, lockfile *Lockfile) error {
	log.Println("installing plugins")
	for _, plugin := range plugins {
		log.Println("installing", plugin.GetName())
		commit, err := CloneRepo(config.PluginsHome, plugin)
		if err != nil {
			return err
		}
		lockfile.Plugins = append(lockfile.Plugins, LokedPlugin{
			Name:   plugin.Name,
			URL:    plugin.URL,
			Commit: commit,
		})
	}
	return nil
}

func UpdatePlugins(config Config, plugins []Plugin, lockfile *Lockfile) error {
	log.Println("updating plugins")
	for _, plugin := range plugins {
		// Check if plugin is already installed in the destination
		if _, err := os.Stat(path.Join(config.PluginsHome, plugin.DirectoryName())); err == nil {
			log.Println("updating", plugin.GetName())
			commit, err := PullRepo(config.PluginsHome, plugin)
			if err != nil {
				return err
			}
			lockfile.Plugins = append(lockfile.Plugins, LokedPlugin{
				Name:   plugin.Name,
				URL:    plugin.URL,
				Commit: commit,
			})
			continue
		}

		// Lest clone the repo
		log.Println("installing", plugin.GetName())
		commit, err := CloneRepo(config.PluginsHome, plugin)
		if err != nil {
			return err
		}
		lockfile.Plugins = append(lockfile.Plugins, LokedPlugin{
			Name:   plugin.Name,
			URL:    plugin.URL,
			Commit: commit,
		})
	}
	return nil
}

func Uninstall(config Config, plugins []Plugin) error {
	log.Println("uninstalling plugins")
	for _, plugin := range plugins {
		log.Println("uninstalling", plugin.Name)
		RemoveRepo(config.PluginsHome, plugin)
	}
	return nil
}

func CloneRepo(home string, plugin Plugin) (string, error) {
	destination := path.Join(home, plugin.DirectoryName())
	log.Println("cloning repository from", plugin.GetURL(), "to", destination)
	repo, err := git.PlainClone(destination, &git.CloneOptions{
		URL:               plugin.GetURL(),
		RecurseSubmodules: git.DefaultSubmoduleRecursionDepth,
		SingleBranch:      true,
		ReferenceName:     plumbing.ReferenceName(plugin.Branch),
		Progress:          os.Stdout,
	})
	if err != nil {
		return "", fmt.Errorf("cannot clone repository from %s: %s", plugin.URL, err)
	}

	head, err := repo.Head()
	if err != nil {
		return "", fmt.Errorf("cannot get repository head: %s", err)
	}

	return head.Hash().String(), nil
}

func PullRepo(home string, plugin Plugin) (string, error) {
	destination := path.Join(home, plugin.DirectoryName())
	log.Println("pulling repository from", plugin.URL, "to", destination)
	repo, err := git.PlainOpen(destination)
	if err != nil {
		return "", fmt.Errorf("cannot open repository: %s", err)
	}

	w, err := repo.Worktree()
	if err != nil {
		return "", fmt.Errorf("cannot get repository worktree: %s", err)
	}

	if err := w.Pull(&git.PullOptions{
		RemoteName: "origin",
		Progress:   os.Stdout,
	}); err != nil && err != git.NoErrAlreadyUpToDate {
		return "", fmt.Errorf("cannot pull repository: %s", err)
	}

	head, err := repo.Head()
	if err != nil {
		return "", fmt.Errorf("cannot get repository head: %s", err)
	}

	return head.Hash().String(), nil
}

func RemoveRepo(home string, plugin Plugin) error {
	destination := path.Join(home, plugin.DirectoryName())
	log.Println("removing repository from", destination)
	return os.RemoveAll(destination)
}

func loadJSON(filePath string, v any) error {
	log.Println("loading file", filePath)
	f, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("cannot open %s: %w", filePath, err)
	}
	defer f.Close()
	if err := json.NewDecoder(f).Decode(v); err != nil {
		return fmt.Errorf("cannot decode %s: %w", filePath, err)
	}

	return nil
}

func saveJSON(filePath string, v any) error {
	log.Println("saving file", filePath)
	f, err := os.Create(filePath)
	if err != nil {
		return fmt.Errorf("cannot create %s: %w", filePath, err)
	}
	defer f.Close()

	decoder := json.NewEncoder(f)
	decoder.SetIndent("", "  ")

	if err := decoder.Encode(v); err != nil {
		return fmt.Errorf("cannot encode %s: %w", filePath, err)
	}

	return nil
}
