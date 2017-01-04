FROM gizra/drupal-lamp

ADD . /var/www/html/Server
WORKDIR /var/www/html/Server

# Add a bash script to finalize all
RUN chmod +x /var/www/html/Server/docker_files/run.sh
ENTRYPOINT ["/var/www/html/Server/docker_files/run.sh"]

EXPOSE 80 3306 22
