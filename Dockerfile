FROM redhat/ubi8
WORKDIR /app
RUN yum install -y java-11-openjdk && yum clean all
RUN yum install -y java-11-openjdk-devel && yum clean all
RUN curl -L -o async-profiler-2.6-linux-x64.tar.gz \
 https://github.com/jvm-profiling-tools/async-profiler/releases/download/v2.6/async-profiler-2.6-linux-x64.tar.gz \
  && tar xf async-profiler-2.6-linux-x64.tar.gz && rm async-profiler-2.6-linux-x64.tar.gz
CMD [ "/bin/bash" ]
