#!/usr/bin/env bats

load helpers

function teardown() {
	swarm_manage_cleanup
	stop_docker
}

@test "docker attach" {
	start_docker 3
	swarm_manage

	# container run in background
	run docker_swarm run -d --name test_container busybox sleep 100
	[ "$status" -eq 0 ]

	# make sure container is up
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" ==  *"test_container"* ]]
	[[ "${lines[1]}" ==  *"Up"* ]]

	# attach to running container
	run docker_swarm attach test_container
	[ "$status" -eq 0 ]
}

@test "docker attach through websocket" {
	CLIENT_API_VERSION="v1.17"
	start_docker 2
	swarm_manage

	#create a container
        run docker_swarm run -d --name test_container busybox sleep 1000

	# test attach-ws api
	# jimmyxian/centos7-wssh is an image with websocket CLI(WSSH) wirtten in Nodejs
	# if connected successfull, it returns two lines, "Session Open" and "Session Closed"
	# Note: with stdout=1&stdin=1&stream=1: it can be used as SSH
	URL="ws://${SWARM_HOST}/${CLIENT_API_VERSION}/containers/test_container/attach/ws?stderr=1"
	run docker run --rm --net=host jimmyxian/centos7-wssh wssh $URL
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[0]}" == *"Session Open"* ]]
	[[ "${lines[1]}" == *"Session Closed"* ]]
}

@test "docker build" {
      start_docker 3
      swarm_manage
      
      run docker_swarm images -q
      [ "$status" -eq 0 ]
      [ "${#lines[@]}" -eq 0 ]

      run docker_swarm build -t test $BATS_TEST_DIRNAME/testdata/build
      [ "$status" -eq 0 ]

      run docker_swarm images -q
      [ "$status" -eq 0 ]
      [ "${#lines[@]}" -eq 1 ]
}

# FIXME
@test "docker commit" {
	skip
}

# FIXME
@test "docker cp" {
	skip
}

# FIXME
@test "docker create" {
	skip
}

@test "docker diff" {
	start_docker 3
	swarm_manage
	run docker_swarm run -d --name test_container busybox sleep 500
	[ "$status" -eq 0 ]

	# make sure container is up
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" ==  *"test_container"* ]]
	[[ "${lines[1]}" ==  *"Up"* ]]

	# no changs
	run docker_swarm diff test_container
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 0 ]

	# make changes on container's filesystem
	run docker_swarm exec test_container touch /home/diff.txt
	[ "$status" -eq 0 ]
	# verify
	run docker_swarm diff test_container
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" ==  *"diff.txt"* ]]
}

# FIXME
@test "docker events" {
	skip
}

# FIXME
@test "docker exec" {
	skip
}

# FIXME
@test "docker export" {
	skip
}

# FIXME
@test "docker history" {
	skip
}

# FIXME
@test "docker images" {
	skip
}

# FIXME
@test "docker import" {
	skip
}

@test "docker info" {
	start_docker 1 --label foo=bar
	swarm_manage
	run docker_swarm info
	[ "$status" -eq 0 ]
	[[ "${lines[3]}" == *"Nodes: 1" ]]
	[[ "${output}" == *"└ Labels:"*"foo=bar"* ]]
}

# FIXME
@test "docker inspect" {
	skip
}

# FIXME
@test "docker kill" {
	skip
}

# FIXME
@test "docker load" {
	skip
}

# FIXME
@test "docker login" {
	skip
}

# FIXME
@test "docker logout" {
	skip
}

# FIXME
@test "docker logs" {
	skip
}

@test "docker port" {
	start_docker 3
	swarm_manage
	run docker_swarm run -d -p 8000 --name test_container busybox sleep 500
	[ "$status" -eq 0 ]

	# make sure container is up
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq  2 ]
	[[ "${lines[1]}" == *"test_container"* ]]
	[[ "${lines[1]}" == *"Up"* ]]

	# port verify
	run docker_swarm port test_container
	[ "$status" -eq 0 ]
	[[ "${lines[*]}" == *"8000"* ]]
}

# FIXME
@test "docker pause" {
	skip
}

@test "docker ps -n" {
	start_docker 1
	swarm_manage
	run docker_swarm run -d busybox sleep 42
	run docker_swarm run -d busybox false
	run docker_swarm ps -n 3
	# Non-running containers should be included in ps -n
	[ "${#lines[@]}" -eq  3 ]

	run docker_swarm run -d busybox true
	run docker_swarm ps -n 3
	[ "${#lines[@]}" -eq  4 ]

	run docker_swarm run -d busybox true
	run docker_swarm ps -n 3
	[ "${#lines[@]}" -eq  4 ]
}

@test "docker ps -l" {
	start_docker 1
	swarm_manage
	run docker_swarm run -d busybox sleep 42
	sleep 1 #sleep so the 2 containers don't start at the same second
	run docker_swarm run -d busybox true
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq  2 ]
	# Last container should be "true", even though it's stopped.
	[[ "${lines[1]}" == *"true"* ]]

	sleep 1 #sleep so the container doesn't start at the same second as 'busybox true'
	run docker_swarm run -d busybox false
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq  2 ]
	[[ "${lines[1]}" == *"false"* ]]
}

# FIXME
@test "docker pull" {
	skip
}

# FIXME
@test "docker push" {
	skip
}

# FIXME
@test "docker rename" {
	skip
}

# FIXME
@test "docker restart" {
	skip
}

# FIXME
@test "docker rm" {
	skip
}

# FIXME
@test "docker rmi" {
	skip
}

# FIXME
@test "docker run" {
	skip
}

# FIXME
@test "docker save" {
	skip
}

# FIXME
@test "docker search" {
	skip
}

# FIXME
@test "docker start" {
	skip
}

# FIXME
@test "docker stats" {
	skip
}

# FIXME
@test "docker stop" {
	skip
}

# FIXME
@test "docker tag" {
	skip
}

@test "docker top" {
	start_docker 3
	swarm_manage

	run docker_swarm run -d --name test_container busybox sleep 500
	[ "$status" -eq 0 ]
	# make sure container is running
	run docker_swarm ps -l
	[ "${#lines[@]}" -eq 2 ]
	[[ "${lines[1]}" == *"test_container"* ]]
	[[ "${lines[1]}" == *"Up"* ]]

	run docker_swarm top test_container
	[ "$status" -eq 0 ]
	[[ "${lines[0]}" == *"UID"* ]]
	[[ "${lines[0]}" == *"CMD"* ]]
	[[ "${lines[1]}" == *"sleep 500"* ]]
}

# FIXME
@test "docker unpause" {
	skip
}

# FIXME
@test "docker version" {
	skip
}

# FIXME
@test "docker wait" {
	skip
}
