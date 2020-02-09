option=''

if [ $# -eq 0 ]; then
    echo '##### git pull #####'
    git pull --recurse-submodules

    if [ `basename \`pwd\``  = 'gokabot-line-dev' ]; then
        echo '##### Option set #####'
        echo '-> For development'
        option='-f docker-compose.debug.yml'
    fi
else
    if [ $1 = '--local' ]; then
        echo '##### Option set #####'
        echo '-> For local'
        option='-f docker-compose.local.yml'
    else
        exit 1
    fi
fi

echo '##### Restart Docker container #####'
docker-compose $option down
docker-compose $option build
docker image prune -f
docker-compose $option up -d
