# MOOC Big Data Pipeline: Distributed Sentiment Analysis

## Overview
This project implements an end-to-end distributed Big Data pipeline to process, clean, and analyze a massive dataset of MOOC (Udemy) customer comments. It transitions a traditional single-machine Pandas/Scikit-learn workflow into a highly scalable, distributed architecture using Apache Hadoop (HDFS) for storage and Apache Spark (PySpark) for distributed computing and machine learning.

The pipeline ingests raw CSV data, performs distributed natural language processing (NLP) including language detection, translation, and lemmatization, and trains scalable Machine Learning models (TF-IDF and Word2Vec) to classify sentiment, saving the optimized model back to HDFS for production serving.

## Features
* **Distributed Storage:** Fault-tolerant data storage using Hadoop HDFS with multiple DataNodes.
* **Scalable Computing:** Apache Spark cluster (Master + Workers) for in-memory distributed data processing.
* **Distributed NLP:** Scalable text cleaning, emoji translation, language detection, and tokenization using PySpark UDFs.
* **Spark MLlib Pipelines:** Distributed training of TF-IDF and Word2Vec models with Logistic Regression and Cross-Validation.
* **Containerized Infrastructure:** Fully reproducible Docker Compose environment tailored for Fedora/SELinux compatibility.

## Tech Stack

| Category | Technology | Version | Purpose |
| :--- | :--- | :--- | :--- |
| Processing | Apache Spark | 3.5.1 | Distributed data processing and ML pipeline |
| Storage | Apache Hadoop (HDFS) | 3.4.1 | Distributed file storage |
| Containerization | Docker & Compose | Latest | Infrastructure orchestration |
| Environment | Jupyter Notebook | pyspark-3.5.1 | Interactive development and execution |
| Language | Python | 3.11+ | Scripting and ML logic |
| NLP & ML | NLTK, spaCy, Spark MLlib | - | Text processing and model training |
| Data Manipulation | PySpark, Pandas | >=2.2.0 | DataFrame operations and evaluation collection |

## Architecture

```text
                Comments.csv
                       │
                       ▼
               ┌───────────────┐
               │  Hadoop HDFS  │◄────────┐
               │  (Raw Data)   │         │
               └───────┬───────┘         │ (Replication)
                       │                 ▼
                       ▼         ┌───────────────┐
               ┌───────────────┐ │  Hadoop HDFS  │
               │ Spark Cluster │ │  (DataNodes)  │
               │ (Master + 2x) │ └───────────────┘
               │ (Workers)     │ 
               └───────┬───────┘
                       │
     ┌─────────────────┼─────────────────┐
     ▼                 ▼                 ▼
Data Cleaning   Language Transl.   Feature Eng. (NLP)
     │                 │                 │
     └─────────────────┼─────────────────┘
                       ▼
               ┌───────────────┐
               │  Hadoop HDFS  │ (Saved as Parquet)
               │ (Processed)   │
               └───────┬───────┘
                       ▼
               ┌───────────────┐
               │  Spark MLlib  │ (TF-IDF / Word2Vec)
               │  CrossVal     │
               └───────┬───────┘
                       ▼
               ┌───────────────┐
               │  Hadoop HDFS  │ (Serialized Pipeline)
               │   (Models)    │
               └───────────────┘

```

## Project Structure

```text
mooc-bigdata/
├── README.md
├── docker-compose.yml
├── jupyter_install-spark.sh
├── Dockerfile.spark
├── Dockerfile.jupyter
├── jupyter/
│   ├── Dockerfile
│   └── requirements.txt
├── hadoop-config/
│   ├── core-site.xml
│   ├── hdfs-site.xml
│   └── start-namenode.sh
├── data/
│   └── raw/
│       └── Comments.csv
├── hdfs/
│   ├── namenode/
│   ├── datanode-1/
│   └── datanode-2/
├── notebooks/
│   ├── 01_preprocessing.ipynb
│   └── 02_training.ipynb
└── models/

```

## Prerequisites

On a completely fresh machine, you will need:

* **Operating System:** Linux (Fedora/Ubuntu/Debian), macOS, or Windows (WSL2). *Note: SELinux compatibility (`:Z` flags) is already configured for Fedora/RHEL environments.*
* **Docker:** Docker Engine and Docker Compose V2.
* **Hardware:** Minimum 16GB RAM recommended (Spark and Hadoop containers require significant memory).
* **Data:** The Udemy `Comments.csv` dataset from Kaggle.

## Installation on a Fresh Machine

### 1. Clone the Repository

```bash
git clone <repository_url> mooc-bigdata
cd mooc-bigdata

```

### 2. Prepare the Data Directory and Dataset

Create the local data directory and place your Kaggle dataset inside it.

```bash
mkdir -p data/raw hdfs/namenode hdfs/datanode-1 hdfs/datanode-2 models
# TODO: VERIFY - Download Comments.csv from Kaggle and place it in data/raw/Comments.csv

```
*Note: Ensure `data/raw/Comments.csv` exists before proceeding.*


### 3. Start the Infrastructure

Build the custom Jupyter image (which installs NLP dependencies) and start the Hadoop/Spark cluster in detached mode.

```bash
docker compose up 

chmod +x setup_data.sh
./setup_data.sh


```


## Running the Data Pipeline

1. **Access JupyterLab:**
Navigate to `http://localhost:8888` in your web browser. (Check terminal logs for the auth token if required: `docker compose logs jupyter`).
2. **Access Spark Master UI:**
Navigate to `http://localhost:8080` to view active workers and application execution graphs.
3. **Access NameNode UI:**
Navigate to `http://localhost:9870` to browse the distributed file system.

### Execution Flow

Inside JupyterLab, create or open the following notebooks and execute them sequentially:

1. **`preprocessing.ipynb`:**
* Connects to `spark://spark-master:7077`.
* Loads `Comments.csv` from HDFS.
* Executes PySpark UDFs for emoji replacement, language detection, translation, and tokenization.
* Writes results to `hdfs://namenode:9000/data/mooc/processed/Comments_cleaned.parquet`.


2. **`model.ipynb`:**
* Loads the cleaned Parquet data.
* Builds `StringIndexer`, `Tokenizer`, `HashingTF`/`IDF`, and `Word2Vec` pipelines.
* Trains Distributed Logistic Regression models.
* Collects evaluation metrics (Pandas >2.2.0) for Confusion Matrices and F1-Scores.
* Serializes and saves the best model to `hdfs://namenode:9000/data/mooc/models/best_sentiment_pipeline`.



## Common Commands

| Task | Command |
| --- | --- |
| **Start Cluster** | `docker compose up -d --build` |
| **Stop Cluster** | `docker compose down` |
| **Check Container Status** | `docker compose ps` |
| **View Spark Master Logs** | `docker compose logs spark-master` |
| **List HDFS Raw Files** | `docker exec -it mooc-namenode hdfs dfs -ls -h /data/mooc/raw` |
| **Monitor Container Resources** | `docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"` |
