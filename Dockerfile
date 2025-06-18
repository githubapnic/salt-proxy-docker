FROM debian:bookworm

# ADD file:3af3091e7d2bb40bc1e6550eb5ea290badc6bbf3339105626f245a963cc11450 in /

CMD ["bash"]

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates netbase && rm -rf /var/lib/apt/lists/*

# ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
## 3.10 key
# ENV GPG_KEY=a035c8c19219ba821ecea86b64e628f8d684696d
## 3.8 Key
ENV GPG_KEY=e3ff2839c048b25c084debe9b26995e310250568


ENV PYTHON_VERSION=3.8.10

RUN set -ex && savedAptMark="$(apt-mark showmanual)" && apt-get update && apt-get install -y --no-install-recommends dpkg-dev gcc libbluetooth-dev libbz2-dev libc6-dev libexpat1-dev libffi-dev libgdbm-dev liblzma-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev make tk-dev wget xz-utils zlib1g-dev $(command -v gpg > /dev/null || echo 'gnupg dirmngr') && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" && export GNUPGHOME="$(mktemp -d)" && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$GPG_KEY" && gpg --batch --verify python.tar.xz.asc python.tar.xz && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } && rm -rf "$GNUPGHOME" python.tar.xz.asc && mkdir -p /usr/src/python && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && rm python.tar.xz && cd /usr/src/python && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && ./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-optimizations --enable-option-checking=fatal --enable-shared --with-system-expat --with-system-ffi --without-ensurepip && make -j "$(nproc)" LDFLAGS="-Wl,--strip-all" PROFILE_TASK='-m test.regrtest --pgo test_array test_base64 test_binascii test_binhex test_binop test_bytes test_c_locale_coercion test_class test_cmath test_codecs test_compile test_complex test_csv test_decimal test_dict test_float test_fstring test_hashlib test_io test_iter test_json test_long test_math test_memoryview test_pickle test_re test_set test_slice test_struct test_threading test_time test_traceback test_unicode ' && make install && rm -rf /usr/src/python && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) -o \( -type f -a -name 'wininst-*.exe' \) \) -exec rm -rf '{}' + && ldconfig && apt-mark auto '.*' > /dev/null && apt-mark manual $savedAptMark && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && rm -rf /var/lib/apt/lists/* && python3 --version

RUN cd /usr/local/bin && ln -s idle3 idle && ln -s pydoc3 pydoc && ln -s python3 python && ln -s python3-config python-config

# ENV PYTHON_PIP_VERSION=20.2.2
ENV PYTHON_PIP_VERSION=24.3.1

ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/5578af97f8b2b466f4cdbebe18a3ba2d48ad1434/get-pip.py

ENV PYTHON_GET_PIP_SHA256=d4d62a0850fe0c2e6325b2cc20d818c580563de5a2038f917e3cb0e25280b4d1

RUN set -ex; savedAptMark="$(apt-mark showmanual)"; apt-get update; apt-get install -y --no-install-recommends wget; wget -O get-pip.py "$PYTHON_GET_PIP_URL"; echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; apt-mark auto '.*' > /dev/null; [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; rm -rf /var/lib/apt/lists/*; python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" ; pip --version; find /usr/local -depth \( \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +; rm -f get-pip.py

CMD ["python3"]
# COPY dir:e9d2a696a21e1bbb9a946315fb82825d90cfb9df3f4c0a3c4db792225b759ee6 in /var/tmp/patches

# RUN apt-get update && apt-get install -y build-essential libssl-dev libffi-dev libxslt-dev -y && rm -rf /var/lib/apt/lists/* && pip --no-cache-dir install msgpack==0.6.2 salt==3006.9 pynetbox==4.0.6 napalm==2.4.0 alerta==5.2.1 psutil==5.4.7 jxmlease==1.0.1 jira==2.0.0 raven==6.10.0 ciscoconfparse==1.4.7 capirca==1.122 netmiko==2.4.2 && find /var/tmp/patches -type f -name '*.patch' | sort -g | xargs -n1 patch -p1 -i && apt-get remove -y patch && rm -rf /var/tmp/patches && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y build-essential libssl-dev libffi-dev libxslt-dev -y && rm -rf /var/lib/apt/lists/* && pip --no-cache-dir install msgpack>=1.0.0 salt==3006.9 pynetbox==7.3.4 napalm alerta==5.2.1 psutil==5.4.7 jxmlease==1.0.1 jira==2.0.0 raven==6.10.0 ciscoconfparse2 capirca==2.0.9 netmiko==4.4.0 && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# RUN pip install salt==3006.9 salt-sproxy==2020.7.0
RUN pip install salt==3006.9 salt-sproxy

# COPY dir:75fd23111664cfe4821c91e9b3d845208d6ea5b5d0cf44b89fa2e7749f6379e5 in /var/tmp/patches

# RUN apt-get update && apt-get install -y ssh tree vim patch && pip install salt==3006.9 salt-sproxy napalm-logs==0.11.0 && find /var/tmp/patches -type f -name '*.patch' | sort -g | xargs -n1 patch -p1 -i && apt-get remove -y patch && rm -rf /var/tmp/patches && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y ssh tree vim nano patch && pip install salt==3006.9 salt-sproxy napalm-logs==0.11.0  && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

RUN echo ${PWD} && ls -lR

COPY run-master.sh /usr/local/bin/run-master.sh

CMD ["/bin/sh" "-c" "\"/usr/local/bin/run-master.sh\""]

RUN pip install napalm-logs==0.11.0 CherryPy==18.9.0 && apt update && apt install -y curl && apt autoremove -y && apt autoclean -y && rm -rf /var/lib/apt/lists/*
