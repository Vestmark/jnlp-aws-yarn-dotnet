FROM vestmarkorg/jnlp-aws-yarn

USER root

# Install .NET CLI dependencies
RUN echo 'deb http://deb.debian.org/debian stretch main' >> /etc/apt/sources.list
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	libc6 \
	libgcc1 \
	libgssapi-krb5-2 \
	libicu57 \
	liblttng-ust0 \
	libssl1.0.2 \
	libstdc++6 \
	zlib1g \
	zip \
	&& rm -rf /var/lib/apt/lists/* sudo

# Install .NET Core SDK
ENV DOTNET_SDK_VERSION 2.2.207
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE true

RUN curl -SL --output dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/022d9abf-35f0-4fd5-8d1c-86056df76e89/477f1ebb70f314054129a9f51e9ec8ec/dotnet-sdk-2.2.207-linux-x64.tar.gz \
	&& dotnet_sha512='9d70b4a8a63b66da90544087199a0f681d135bf90d43ca53b12ea97cc600a768b0a3d2f824cfe27bd3228e058b060c63319cd86033be8b8d27925283f99de958' \
	&& echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
	&& mkdir -p /usr/share/dotnet \
	&& tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
	&& rm dotnet.tar.gz \
	&& ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

USER jenkins

RUN dotnet tool install --global dotnet-sonarscanner
RUN echo '#!/bin/bash\n\
cat << \EOF >> ~/.bash_profile\n\
export PATH="$PATH:/home/root/.dotnet/tools"\n\
EOF\n'\
> ~/updatePath.sh
RUN chmod a+x updatePath.sh
RUN ./updatePath.sh
RUN rm ./updatePath.sh