FROM guibrushdotcom/java7

RUN apt-get update
RUN apt-get install -y maven
RUN apt-get install -y postgresql postgresql-contrib postgresql-client

# Set the password for the user postgres
RUN echo "postgres:postgres" | chpasswd \
		&& usermod -a -G staff postgres

USER postgres

# Create the database
RUN /etc/init.d/postgresql start \
		&& psql --command "ALTER USER postgres PASSWORD 'postgres';" \
		&& createdb -O postgres shop

RUN cd /tmp \
		&& wget https://github.com/mayocat/mayocat-shop/releases/download/mayocat-shop-0.20.1/mayocat-shop-distribution-0.20.1.zip \
		&& unzip mayocat-shop-distribution-0.20.1.zip

# Copy the app in /var/local/www
RUN mkdir /var/local/www \
		&& cp -rf /tmp/mayocat-shop-distribution-0.20.1 /var/local/www/mayocat-0201

# Launch the app
RUN cd /var/local/www/mayocat-0201 \
		&& ./bin/migrate.sh &

# Get the modified configuration file and copy to app directory
RUN cd /tmp \
		&& git clone https://github.com/guibrushdotcom/mayocat-configuration.git \
		&& cp /tmp/mayocat-configuration/mayocat.yml /var/local/www/mayocat-0201/configuration/

# Launch the app
RUN cd /tmp/mayocat-shop-distribution-0.20.1 \
		&& ./bin/startup.sh &
			
EXPOSE 8080