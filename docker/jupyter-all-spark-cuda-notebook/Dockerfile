ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG JUPYTER_VERSION
ARG FLAVOUR=all-spark

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyter/${FLAVOUR}-notebook:${JUPYTER_VERSION}

# ARG CUDA_MIRROR=https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/
ARG CUDA_MIRROR=https://nexus.nrtn.dev/repository/apt-cuda/

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# CUDA
# https://gitlab.com/nvidia/container-images/cuda
ENV CUDA_MIRROR ${CUDA_MIRROR}

# Base part
# https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/12.2.0/ubuntu2204/base/Dockerfile?ref_type=heads
ENV NVARCH x86_64

ENV NVIDIA_REQUIRE_CUDA "cuda>=12.2 brand=tesla,driver>=450,driver<451 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=525,driver<526 brand=unknown,driver>=525,driver<526 brand=nvidia,driver>=525,driver<526 brand=nvidiartx,driver>=525,driver<526 brand=geforce,driver>=525,driver<526 brand=geforcertx,driver>=525,driver<526 brand=quadro,driver>=525,driver<526 brand=quadrortx,driver>=525,driver<526 brand=titan,driver>=525,driver<526 brand=titanrtx,driver>=525,driver<526"
ENV NV_CUDA_CUDART_VERSION 12.2.53-1
ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-12-2

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && curl -fsSLo /etc/apt/keyrings/cuda-archive-keyring.asc https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${NVARCH}/3bf863cc.pub \
    && echo "deb [signed-by=/etc/apt/keyrings/cuda-archive-keyring.asc] ${CUDA_MIRROR} /" > /etc/apt/sources.list.d/cuda-ubuntu2204-${NVARCH}.list

ENV CUDA_VERSION 12.2.0

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-12-2=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

# Runtime Part
# https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/12.2.0/ubuntu2204/runtime/Dockerfile?ref_type=heads
ENV NV_CUDA_LIB_VERSION 12.2.0-1

ENV NV_NVTX_VERSION 12.2.53-1
ENV NV_LIBNPP_VERSION 12.1.1.14-1
ENV NV_LIBNPP_PACKAGE libnpp-12-2=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION 12.1.1.53-1

ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-12-2
ENV NV_LIBCUBLAS_VERSION 12.2.1.16-1
ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-12-2=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-12-2=${NV_NVTX_VERSION} \
    libcusparse-12-2=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME}

# Devel Part
# https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/12.2.0/ubuntu2204/devel/Dockerfile?ref_type=heads
ENV NV_CUDA_CUDART_DEV_VERSION 12.2.53-1
ENV NV_NVML_DEV_VERSION 12.2.81-1
ENV NV_LIBCUSPARSE_DEV_VERSION 12.1.1.53-1
ENV NV_LIBNPP_DEV_VERSION 12.1.1.14-1
ENV NV_LIBNPP_DEV_PACKAGE libnpp-dev-12-2=${NV_LIBNPP_DEV_VERSION}

ENV NV_LIBCUBLAS_DEV_VERSION 12.2.1.16-1
ENV NV_LIBCUBLAS_DEV_PACKAGE_NAME libcublas-dev-12-2
ENV NV_LIBCUBLAS_DEV_PACKAGE ${NV_LIBCUBLAS_DEV_PACKAGE_NAME}=${NV_LIBCUBLAS_DEV_VERSION}

ENV NV_CUDA_NSIGHT_COMPUTE_VERSION 12.2.0-1
ENV NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE cuda-nsight-compute-12-2=${NV_CUDA_NSIGHT_COMPUTE_VERSION}

ENV NV_NVPROF_VERSION 12.2.60-1
ENV NV_NVPROF_DEV_PACKAGE cuda-nvprof-12-2=${NV_NVPROF_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-dev-12-2=${NV_CUDA_CUDART_DEV_VERSION} \
    cuda-command-line-tools-12-2=${NV_CUDA_LIB_VERSION} \
    cuda-minimal-build-12-2=${NV_CUDA_LIB_VERSION} \
    cuda-libraries-dev-12-2=${NV_CUDA_LIB_VERSION} \
    cuda-nvml-dev-12-2=${NV_NVML_DEV_VERSION} \
    ${NV_NVPROF_DEV_PACKAGE} \
    ${NV_LIBNPP_DEV_PACKAGE} \
    libcusparse-dev-12-2=${NV_LIBCUSPARSE_DEV_VERSION} \
    ${NV_LIBCUBLAS_DEV_PACKAGE} \
    ${NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_DEV_PACKAGE_NAME}
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

USER $NB_UID

RUN pip install --upgrade jupyterlab jupyterlab-git nbgitpuller \
    && jupyter lab extension enable --sys-prefix nbgitpuller
