from fastapi import FastAPI

app = FastAPI(title="DevSecOps API")

@app.get("/")
def read_root():
    return {"status": "healthy", "message": "Automated DevSecOps Pipeline Active"}