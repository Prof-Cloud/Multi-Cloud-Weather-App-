# Multi-Cloud Weather Tracker

<img width="480" height="721" alt="Screenshot 2026-04-04 at 11 38 54 AM" src="https://github.com/user-attachments/assets/5ea05f24-a096-4c0d-8b99-150a9afdfb49" />


In this project, I built a resilient, multi-cloud weather tracking web app that continues to run even if a cloud provider goes down. The app is hosted on AWS S3 & CloudFront as the primary, with Azure Blob Storage as a standby. Traffic automatically switches using Route 53 health checks if the primary fails, and everything is fully managed with Terraform. Users can check the weather without ever noticing an outage.  


## What I Built

AWS S3 & CloudFront
  - Hosts the main version of the website
  - Serves the weather data quickly via CloudFront's CDN

Azure Blob Storage (Standby)
  - Acts as a backup hosting solution
  - Kicks in automatically if AWS goes down

Route 53
  - Monitors the health of the primary site
  - Automatically switches traffic to Azure if AWS fails


