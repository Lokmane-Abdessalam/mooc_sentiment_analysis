#must be run after the containers are up and running, otherwise it will fail

docker exec -it mooc-namenode hdfs dfs -mkdir -p /data/mooc/raw
docker exec -it mooc-namenode hdfs dfs -mkdir -p /data/mooc/processed
docker exec -it mooc-namenode hdfs dfs -mkdir -p /data/mooc/models

docker cp data/raw/sample_Comments.csv mooc-namenode:/tmp/sample_Comments.csv

docker exec -it mooc-namenode hdfs dfs -put /tmp/sample_Comments.csv /data/mooc/raw/

docker exec -it mooc-namenode hdfs dfs -ls -h /data/mooc/raw



for c in mooc-spark-worker mooc-spark-worker-2; do
  docker exec -u root $c bash -c "cd /usr/share/nltk_data/corpora && python -m zipfile -e wordnet.zip . "
done



docker exec mooc-namenode hdfs dfs -chown -R hadoop:supergroup /data/mooc
