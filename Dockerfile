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
ENV DOTNET_SDK_VERSION 3.1.302
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE true

RUN curl -SL --output dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/c505a449-9ecf-4352-8629-56216f521616/bd6807340faae05b61de340c8bf161e8/dotnet-sdk-6.0.201-linux-x64.tar.gz \
	&& dotnet_sha512='a4d96b6ca2abb7d71cc2c64282f9bd07cedc52c03d8d6668346ae0cd33a9a670d7185ab0037c8f0ecd6c212141038ed9ea9b19a188d1df2aae10b2683ce818ce' \
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