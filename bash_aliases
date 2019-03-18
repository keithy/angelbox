alias dockly='docker run -it --rm --name dockly -v /var/run/docker.sock:/var/run/docker.sock lirantal/dockly'
alias mysql='cd ~/AngelBox ; docker-compose run --rm  mysql_cli'
alias docker-map='cat docker-compose.yml | docker run -i funkwerk/compose_plantuml --link-graph | docker run -i think/plantuml -tpng | imgcat'
