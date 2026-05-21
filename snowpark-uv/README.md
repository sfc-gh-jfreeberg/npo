# Snowpark Deployment with uv



```
uv sync --managed-python
```

replace '<your_connection_name>' in main.py with your connection name in `./snowflake/connections.toml` or pass in a dictionary with your username, password, and account information <add URL to docs here>

```
uv run src/main.py
```

```
chmod +x deploy.sh
./deploy.sh
```