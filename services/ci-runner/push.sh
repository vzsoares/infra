export AWS_PROFILE=myself

REGION="$(aws configure get region)"
IMAGE=zenhalab-ci-runner-prod:1
BASE_REGISTRY="public.ecr.aws/j5s7c7d2"

REGISTRY="${BASE_REGISTRY}/${IMAGE}"

docker build -t "${REGISTRY}" .

aws ecr-public get-login-password \
    --region "${REGION}" |
    docker login \
        --username AWS \
        --password-stdin "${BASE_REGISTRY}"

docker push "${REGISTRY}"
