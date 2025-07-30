FROM debian:bookworm

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get install -y curl jq rsync procps gcc-multilib lib32stdc++6 zlib1g-dev:i386 libssl-dev:i386 pkg-config:i386 libstdc++6 libstdc++6:i386 libcurl4:i386

RUN groupadd -g 6969 ss13 && \
	useradd -s /bin/bash --uid 6969 --gid 6969 ss13

USER ss13
WORKDIR /ss13_server
ENTRYPOINT ["bash", "tools/server/start.sh"]
