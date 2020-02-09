option=''
container_name='gokabot-line'

if [ $# -eq 0 ]; then
    echo '##### git pull #####'
    git pull --recurse-submodules

    if [ `basename \`pwd\``  = 'gokabot-line-dev' ]; then
        echo '##### Set option #####'
        echo '-> For development'
        option='-f docker-compose.debug.yml'
        container_name='gokabot-line-dev'
    fi
else
    if [ $1 = '--local' ]; then
        echo '##### Set option #####'
        echo '-> For local'
        option='-f docker-compose.local.yml'
        container_name='gokabot-line-local'
    else
        exit 1
    fi
fi

echo '##### Restart Docker container #####'
docker-compose $option down
docker-compose $option build
docker image prune -f
docker-compose $option up -d

echo '##### Run RSpec-test on Docker container #####'
docker exec -it $container_name bundle exec rspec

echo '##### Finish! #####'
