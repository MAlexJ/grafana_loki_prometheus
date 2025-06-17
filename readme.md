### Docker self hosted Grafana Loki

1. Install plugin

```
    docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
```

2. Update or create if not exist `/etc/docker/daemon.json` file

```
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "http://127.0.0.1:3100/loki/api/v1/push",
    "loki-batch-size": "400",
    "loki-retries": "3",
    "loki-timeout": "10s"
  }
}
EOF
```

note:

* loki-url = http://loki:3100/loki/api/v1/push is url in docker-compose file

2.1. Make sure the plugin is installed and active:

`docker plugin ls | grep loki`

2.2. Check that Docker is really picking up daemon.json

`docker info | grep "Logging Driver"`

2.3. Check for errors in Docker logs

`sudo journalctl -u docker | grep loki`

3. Restart docker

```
sudo systemctl restart docker
```

4. Verify docker status

```
sudo systemctl status docker
```

or logs

```
journalctl -u docker --since "1 minute ago"
```

5. Run `docker run --rm alpine echo "hello loki"` and
   verify logs in Grafana → Explore → Loki datasource : {container_name="alpine"}
