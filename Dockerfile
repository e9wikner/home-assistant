FROM homeassistant/home-assistant:0.40
MAINTAINER Timo Taskinen <timo.taskinen@iki.fi>

# Add Telldus repository
RUN echo "deb-src http://download.telldus.com/debian/ stable main" >> /etc/apt/sources.list.d/telldus.list
RUN curl -sSL http://download.telldus.se/debian/telldus-public.key | apt-key add -

# Install dependencies. Compile and install telldusd and ruuvitag_sensor
RUN apt-get update
RUN apt-get install -y build-essential python3-dev bluez bluez-hcidump sudo
RUN apt-get build-dep -y telldus-core
RUN apt-get install -y cmake libconfuse-dev libftdi-dev help2man
RUN apt-get --compile source telldus-core
RUN dpkg --install *.deb
RUN pip3 install ruuvitag_sensor

# Install and configure Supervisor
RUN apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Specify health check for Docker
HEALTHCHECK CMD curl --fail http://localhost:8123 || exit 1
