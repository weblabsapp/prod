#
# Weblabs Dockerfile
# Copyrights to Wajdi Jurry <github.com/wajdijurry>
#
FROM php:7.4-cli

LABEL maintainer="Wajdi Jurry <github.com/wajdijurry>"

# Important! To prevent this warning "debconf: unable to initialize frontend"
ARG DEBIAN_FRONTEND=noninteractive

# Update apt repos
RUN echo "Updating repos ..." && apt-get -y update > /dev/null
RUN apt-get install -yq apt-utils git 2>&1 | grep -v "debconf: delaying package configuration, since apt-utils is not installed"

# Return working directory to its default state
WORKDIR /app

# Add deploy keys
RUN mkdir /root/.ssh/
COPY .ssh /root/.ssh/
RUN chmod -R 600 /root/.ssh

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Clone project from remote git repository (master) branch
RUN echo "Getting project files ..."
RUN git -C . pull || git clone git@github.com:weblabsapp/app.git .

# Permit artisan to be executable
RUN chmod +x artisan

# Install required tools and dependencies
RUN chmod +x utilities/install-dependencies.sh && ./utilities/install-dependencies.sh

# Install required PHP extensions
RUN chmod +x utilities/install-php-extensions.sh && ./utilities/install-php-extensions.sh

# Install composer & dependencies
RUN echo "Installing Composer" && rm -rf vendor composer.lock && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer clearcache && \
    composer install

# Clear previous cache
RUN php artisan optimize:clear