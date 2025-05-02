#!/bin/bash
images=( "golang:latest" "debian:bookworm" "debian:trixie" "ubuntu:focal" "ubuntu:jammy" "ubuntu:noble" "ubuntu:oracular" "ubuntu:plucky" "fedora:40" "fedora:41" "fedora:42" "busybox" "buildx-bin:0.20.1" "compose-bin:v2.33.1" "docker:dind" "docker:dind" "golang:1.23.8-bookworm" "golang:1.23.8-alpine3.21" "buildx-bin:0.23.0" "compose-bin:v2.35.1" "registry:2.8.3" "alpine:3.21" "golang:1.23.8-alpine" )
for i in "${!images[@]}"; do
    docker pull "public.ecr.aws/docker/library/${images[i]}"
    docker tag public.ecr.aws/docker/library/"${images[i]}" "${images[i]}"
done