(define-module (home lexidoo-home)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services ssh)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp))

;; =============================================================================
;; Packages
;; =============================================================================
(define %my-home-packages
  (map specification->package
       '(;; GUI Apps, Icons, & Fonts
	 "librewolf" "icedove-minimal" "vlc" "krita" "pinentry" "flameshot"
	 "nss-certs" "adwaita-icon-theme"
	 "font-liberation" "font-google-noto" "font-google-noto-serif-cjk" "font-google-noto-emoji"
	 "font-nerd-fira-code" "font-nerd-symbols"
	 "xclip" "ncurses" "cutter"
	 ; emacs vterm requirements
	 "cmake" "make" "gcc-toolchain" "libtool" "emacs-vterm"
	 
	 ;; Coding & Editors (Guile is provided by the system)
	 "go" "gopls" "jujutsu" "zig" "zig-zls" "rust" "perl"
	 "emacs-lucid" "emacs-geiser" "emacs-geiser-guile" "neovim"
	 
	 ;; CLI Tools
	 "bat" "btop" "curl" "cowsay" "gnupg" "fzf" "jq" "lsd"
	 "neofetch" "nushell" "pavucontrol" "pinentry" "pv" "ripgrep"
	 "rsync" "tmux" "tree" "yt-dlp" "zoxide"
	 "ltrace" "strace"
	 
	 ;; Networking & Archives
	 "mtr" "nmap" "7zip" "pigz" "unzip" "zip" "zstd")))

;; =============================================================================
;; Shell Configuration (Fish)
;; =============================================================================
(define %my-fish-config
  (service home-fish-service-type
	   (home-fish-configuration
	    (environment-variables
	     '(("LANG"          . "en_US.UTF-8")
	       ("LANGUAGE"      . "en_US.UTF-8")
	       ("EDITOR"     . "nvim")))
	    (aliases
	     '(("cat" . "bat")
	       ("ls" . "lsd")
	       ("tb" . "ncat termbin.com 9999")
	       ("v" . "nvim")))
	    (config
	     (list (plain-file "rc"
			       "eval \"$(guix package --search-paths -p ~/.config/guix/current -p ~/.guix-profile -p ~/.guix-home/profile -p /run/current-system/profile)\"

# Only add strictly local development paths. Guix handles system bins automatically.
fish_add_path -P -p /run/setuid-programs
fish_add_path -P -a ~/perl5/bin ~/go/bin ~/.local/bin

zoxide init fish | source
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

function fish_greeting; echo 'Hello, there' | cowsay -f small; end

function fish_prompt
  set -l last_pipestatus $pipestatus
  set -lx __fish_last_status $status
  set -l prompt_status (__fish_print_pipestatus '[' ']' '|' (set_color red) (set_color red) $last_pipestatus)
  echo -s (set_color purple)'# '(set_color blue)$USER(set_color normal)' @ '(set_color green)$hostname(set_color normal)' in '(set_color yellow)(prompt_pwd --full-length-dirs 2)(set_color normal) (fish_vcs_prompt) ' ' $prompt_status
  echo -n (set_color red)'$ '(set_color normal)
end
fish_config theme choose None
"))))))

;; =============================================================================
;; SSH Configuration
;; =============================================================================
(define %my-ssh-config
  (service home-openssh-service-type
	   (home-openssh-configuration
	    (hosts
	     (list (openssh-host (name "github.com") (user "git") (identity-file "~/.ssh/github"))
		   (openssh-host (name "codeberg.org") (user "git") (identity-file "~/.ssh/github"))
		   (openssh-host (name "lexihk") (host-name "lexiz.xyz") (user "azz") (port 2200))
		   (openssh-host (name "lexijarod") (host-name "91.181.156.239") (user "root") (port 7210) (identity-file "~/.ssh/lexidoo"))
		   (openssh-host (name "lexipine") (host-name "192.168.0.13") (user "azz") (port 2200) (identity-file "~/.ssh/lexipine"))
		   (openssh-host (name "lexisense") (host-name "10.38.0.1") (user "admin") (port 22) (identity-file "~/.ssh/pfsense_odoo"))
		   (openssh-host (name "rincewind") (host-name "rincewind.trouble.is") (user "azz") (port 22) (identity-file "~/.ssh/rincewind"))
		   (openssh-host (name "labodoo") (host-name "10.31.0.50") (user "odoo") (port 22) (identity-file "~/.ssh/labodoo"))
		   (openssh-host (name "lexidoo") (host-name "10.38.0.5") (user "sibl") (port 2200) (identity-file "~/.ssh/lexidoo"))))
	    (authorized-keys
	     (list
	      (plain-file "lexipine.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHuFK16nVWpdxlZlGWoHwCMDLUtbP9uvJwpi7/Comx9j sibl@sibl"))))))

;; =============================================================================
;; Shepherd Services
;; =============================================================================
(define %emacs-service
  (shepherd-service
   (documentation "Run the Emacs daemon")
   (provision '(emacs))
   (start #~(make-forkexec-constructor
	     '("emacs" "--fg-daemon" "--debug-init")
	     #:log-file (string-append (getenv "HOME") "/log/emacs.log")))
   (stop #~(make-kill-destructor))))

;; =============================================================================
;; Assemble the Home Environment
;; =============================================================================
(home-environment
 (packages %my-home-packages)
 (services (cons*
	    %my-fish-config
	    %my-ssh-config
	    ;; (service home-pipewire-service-type
	    ;; 	     (home-pipewire-configuration
	    ;; 	      (enable-pulseaudio? #t))) ; Enables PulseAudio emulation layer
	    (service home-shepherd-service-type
		     (home-shepherd-configuration
		      (services (list %emacs-service))))
	    %base-home-services)))
