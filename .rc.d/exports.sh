# load all files from .sonatype directory
if [ -d $HOME/.sonatype ]; then
  for file in $HOME/.sonatype/*.sh; do
    source $file
  done
fi
