# The name of the nixosConfiguration in the flake
NIXNAME ?= home

nix/install:
	sh <(curl -L https://nixos.org/nix/install)

nix/clear:
	nix-collect-garbage -d

niv/install:
	nix-env -iA nixpkgs.niv

switch:
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#${NIXNAME}"
	./result/activate

test:
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#${NIXNAME}"
