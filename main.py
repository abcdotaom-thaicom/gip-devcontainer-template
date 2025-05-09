"""
Main script for testing the development environment.
Run: python main.py
"""

import platform
import geopandas as gpd

def get_runtime_info():
    info = {
        "python_version": platform.python_version(),
        "geopandas_version": gpd.__version__,
        "device": "CPU"
    }

    return info

if __name__ == "__main__":
    print("Environment Check Passed:")
    for k, v in get_runtime_info().items():
        print(f"  {k}: {v}")
