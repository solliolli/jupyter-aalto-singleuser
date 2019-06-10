
# Must end it slash
AALTO_NEWHOME="${AALTO_NEWHOME:-/notebooks/.home/}"

mkdir -p "$AALTO_NEWHOME"

# If a directory, it must end it slash or else the dir won't be created.
for path in $AALTO_EXTRA_HOME_LINKS .gitconfig .local/share/jupyter/nbgrader_cache/ .ssh/ ; do
    dirname=$(dirname "$path")
    basename=$(basename "$path")
    mkdir -p $HOME/"$dirname"
    case "$path" in
    */)
        # This is a directory link
        mkdir -p "$AALTO_NEWHOME/$path"
        ln -sTf "$AALTO_NEWHOME/$path" $HOME/"${path%/}"
        ;;
    *)
        # Regular file
        touch "$AALTO_NEWHOME/$path"
        ln -sTf "$AALTO_NEWHOME/$path" $HOME/"$path"
        ;;
    esac
done

unset path dirname basename
