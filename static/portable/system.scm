(define-module (systems lizz)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (gnu system)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu services desktop)
  #:use-module (gnu services linux)
  #:use-module (gnu services xorg)
  #:use-module (gnu services audio)
  #:use-module (gnu services lightdm)
  #:use-module (gnu services cups)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages linux)
  #:use-module (guix channels)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd))

(define %my-channels
  (list (channel
	 (name 'sibl)
	 (url "https://github.com/4zv4l/sibl-channel")
	 (branch "main")
	 (introduction
	  (make-channel-introduction
	   "749146d77482a79c5cbfc8c6786f8edc670fa2af"
	   (openpgp-fingerprint "F656 64BF 2D60 DA21 095F CA50 7FD2 BABC CDDE 5BF1"))))
	(channel
	 (name 'nonguix)
	 (url "https://gitlab.com/nonguix/nonguix")
	 (branch "master")
	 (introduction
	  (make-channel-introduction
	   "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
	   (openpgp-fingerprint "2A39 3FFF 68F4 EF7A 3D29 12AF 6F51 20A0 22FB B2D5"))))
	(channel
	 (name 'guix)
	 (url "https://codeberg.org/guix/guix.git")
	 (branch "master")
	 (introduction
	  (make-channel-introduction
	   "9edb3f66fd807b096b48283debdcddccfea34bad"
	   (openpgp-fingerprint "BBB0 2DDF 2CEA F6A8 0D1D E643 A2A0 6DF2 A33A 54FA"))))))

(operating-system
 (kernel linux)
 (firmware (list linux-firmware sof-firmware))
 (initrd microcode-initrd )
 (host-name "lizz")
 (timezone "Asia/Hong_Kong")
 (locale "en_US.utf8")
 (keyboard-layout (keyboard-layout "us"))

 (users (cons* (user-account
		(name "sibl")
		(group "users")
		(supplementary-groups '("wheel" "netdev" "audio" "video" "lp" "input"))
		(shell (file-append (specification->package "fish") "/bin/fish"))
		(home-directory "/home/sibl"))
	       %base-user-accounts))

 (packages (append (map specification->package
			'("blueman"
			  "xfce4-pulseaudio-plugin"
			  "xfce4-whiskermenu-plugin"
			  "xscreensaver"
			  "xdg-desktop-portal"
			  "xdg-desktop-portal-gtk"
			  "alsa-ucm-conf"
			  "gvfs"
			  "glib-networking"
			  "flatpak"
			  "vim"
			  "emacs"
			  "tmux"
			  "htop"
			  "nmap"
			  "git"
			  "rsync"
			  "zip"
			  "unzip"
			  "smartmontools"
			  "gnome-disk-utility"))
		   %base-packages))
 (services
  (append (list (service xfce-desktop-service-type)
		; if wanna switch to wayland, can remove and use default gdm
		(service lightdm-service-type
			 (lightdm-configuration
			  (greeters
			   (list (lightdm-gtk-greeter-configuration
					;(background "#2c3743") cannot pass color at the moment, only file
				  (theme-name "Adwaita-dark")
				  (icon-theme-name "Adwaita"))))))
		(service zram-device-service-type
                        (zram-device-configuration
                         (size "4G")                     
                         (compression-algorithm 'zstd) 
                         (priority 100)))
		(service earlyoom-service-type)
		(service bluetooth-service-type)
		(service nftables-service-type)
		(service openssh-service-type
			 (openssh-configuration
			  (port-number 22)
			  (permit-root-login #f)
			  (password-authentication? #f)))
		(service cups-service-type
			 (cups-configuration
			  (web-interface? #t)
			  (extensions
			   (list cups-filters epson-inkjet-printer-escpr hplip-minimal brlaser)))))
	  (modify-services %desktop-services
			   (delete pulseaudio-service-type)
			   (delete gdm-service-type)
			   (elogind-service-type
			    config => (elogind-configuration
				       (inherit config)
				       (idle-action 'ignore)
				       (handle-lid-switch 'ignore)
				       (handle-lid-switch-docked 'ignore)
				       (handle-lid-switch-external-power 'ignore)))
			   (guix-service-type
			    config => (guix-configuration
				       (inherit config)
				       (channels %my-channels)
				       (substitute-urls
					(append '("https://substitutes.nonguix.org" "https://nonguix-proxy.ditigal.xyz" "https://cache-test.guix.moe")
						%default-substitute-urls))
				       (authorized-keys
					(append (list (plain-file "nonguix.pub"
								  "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
						%default-authorized-guix-keys)))))))

 (bootloader
  (bootloader-configuration
   (bootloader grub-efi-removable-bootloader)
   (targets '("/boot/efi"))
   (keyboard-layout keyboard-layout)))

 (mapped-devices
  (list (mapped-device
	 (source (uuid "f5563080-8e17-486a-974e-f5d14200482a"))
	 (target "cryptroot")
	 (type luks-device-mapping))))

 (file-systems
  (append
   (map (lambda (item)
	  (file-system
	   (device "/dev/mapper/cryptroot")
	   (mount-point (car item))
	   (type "btrfs")
	   (flags '(no-atime))
	   (options (cadr item))
	   (dependencies mapped-devices)))
	'(("/"   "compress=zstd,subvol=@")
	  ("/gnu" "compress=zstd,subvol=@gnu")
	  ("/home" "compress=zstd,subvol=@home")))
   (list (file-system
	  (mount-point "/boot/efi")
	  (device (uuid "DC37-E0E3" 'fat))
	  (type "vfat")))
   %base-file-systems)))
