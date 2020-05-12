FROM john0879/jnlp-aws-yarn

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
ENV DOTNET_SDK_VERSION 2.1.804
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE true

RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
	&& dotnet_sha512='82b039856dadd2b47fa56a262d1a1a389132f0db037d4ee5c0872f2949c2cd447c33a978e1f532783119aa416860e03f26b840863ca3a97392a4b77f8df5bf66' \
	&& echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
	&& mkdir -p /usr/share/dotnet \
	&& tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
	&& rm dotnet.tar.gz \
	&& ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

USER jenkins

RUN dotnet tool install --global dotnet-sonarscanner --version 4.9.0
RUN echo '#!/bin/bash\n\
cat << \EOF >> ~/.bash_profile\n\
export PATH="$PATH:/home/root/.dotnet/tools"\n\
EOF\n'\
> ~/updatePath.sh
RUN chmod a+x updatePath.sh
RUN ./updatePath.sh
RUN rm ./updatePath.sh