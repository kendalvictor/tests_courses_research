py-cloud-fn hello http --python_version ${PYTHON_VERSION:-2.7} -p -f function.py && \
cd cloudfn/target && gcloud beta functions deploy hello \
--trigger-http --stage-bucket $STAGE_BUCKET --memory 2048MB && cd ../..