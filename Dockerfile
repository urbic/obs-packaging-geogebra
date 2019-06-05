FROM opensuse/leap:15.1

WORKDIR /build

COPY NAME VERSION *.tar.xz Makefile *.patch *.m4 /build/

RUN useradd -d /build build; \
	chown build /build

# Install any needed packages
RUN zypper -n --gpg-auto-import-keys ar -f 'https://download.opensuse.org/repositories/home:concyclic:java/openSUSE_Leap_15.1/home:concyclic:java.repo'; \
	zypper -n --gpg-auto-import-keys in -y \
		java-11-openjdk \
		java-11-openjdk-devel \
		java-11-openjdk-javadoc \
		javapackages-tools \
		git \
		m4 \
		make \
		openjfx \
		patch \
		tar \
		xz;

USER build

# Define environment variable
ENV TERM linux
ENV JAVA_HOME /usr/lib64/jvm/java-11-openjdk

CMD make
