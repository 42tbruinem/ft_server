CONTAINER_ID=$(docker container ls | grep "tbruinem/ft_server" | tr " " \\n | head -1)

docker exec -it $CONTAINER_ID bash /switch_index.sh $1