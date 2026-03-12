import os, logging
from django.core.exceptions import ImproperlyConfigured

logging.basicConfig(level=logging.INFO)

# Determine the environment (default to local)
env = os.getenv("ENV", "local")
valid_envs = {"local", "staging", "production", "test"}
if env not in valid_envs:
    raise ImproperlyConfigured(
        f"Invalid ENV '{env}'. Must be one of: {valid_envs}"
    )

# Import the corresponding settings module
module_path = f"config.settings.{env}"
module = __import__(module_path, globals(), locals(), ["*"])
if os.environ.get("RUN_MAIN") == "true": # Only log once when the server starts, not on every reload
    logging.warning(f"Running with {env.upper()} settings")
# Copy all attributes from the module into this namespace
for attr in dir(module):
    if not attr.startswith("_"):
        globals()[attr] = getattr(module, attr)
