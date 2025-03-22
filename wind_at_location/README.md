# Reask Historical and Probabilistic Wind At Location (WaL) Data

This repository contains R scripts that retrieve location-level wind event data via the Reask API, process the responses to extract event data, construct a pivot table, and save the results in CSV and Parquet formats. The repository also contains an authentication file to be completed with your personal credentials, and a sample `locations.csv` file.

To do in short:
- Clone or download this repo.
- Install R and RStudio.
- Open the project file `.Rproj` in RStudio.
- Open the `API_Authentication.r` script and enter your personal credentials.
- Open and run the script `API_WaL_Master.r`.

---

## Overview

- **API_WaL_Master.r:**  
  Master file to set the hazard parameters and run both the Metryc and DeepCyc queries.
- **API_metryc_tcwinds_events.r:**  
  Retrieves historical data from the Reask API based on DeepCyc.
- **API_deepcyc_tcwinds_events.r:**  
  Retrieves probabilistic data from the Reask API based on DeepCyc.
- **API_Authentication.r:**  
  Authenticates with the Reask API using your credentials.
- **locations.csv:**  
  A sample CSV file containing location data (id, lat, lon, and limit). Modify this file with your actual locations. lat and lon must be included, id and limit is not required.
- **Output Files:**  
  The processed results and meta data are saved as CSV and Parquet files.
- **API_WaL.Rproj:**  
  R project file to set your working directory.

---

## Prerequisites

- **R** (version 3.6 or later recommended)
- Recommended IDE: [RStudio](https://www.rstudio.com/)
- **Git** (if you plan to clone or pull updates from the repository)

### Required R Packages

Install the following packages if you haven't already:

```r
install.packages(c("httr", "data.table", "arrow", "here", "jsonlite"))
```

---

## Installation / Setup

Follow these steps to set up the project on your machine:

1. **Navigate to the Parent Directory for Cloning:**

   - **Windows Users:**  
     Open the Command Prompt and navigate to the folder where you want to store the repository. For example:
     ```cmd
     cd "C:\Users\DavidSchmid\Documents\MyProjects"
     ```
     
   - **Mac Users:**  
     Open the Terminal and navigate to the folder where you want to store the repository. For example:
     ```bash
     cd "/Users/yourusername/Documents/MyProjects"
     ```

2. **Clone or Download the Repository:**

   - **Clone:**  
     Run the following command in your terminal:
     ```bash
     git clone https://github.com/reaskearth/parametrics.git
     ```
     This creates a new folder (e.g. `parametrics`) containing the repository.
     
   - **Download:**  
     Alternatively, click the **"Download ZIP"** button on the GitHub repository page, unzip the folder, and move it to your desired location.

3. **Open the Project in RStudio:**

   The repository includes an `.Rproj` file. Open this file in RStudio, and it will automatically set your working directory to the repository root. This ensures that all relative paths work correctly.

4. **Project Structure:**

   Your repository should have a structure similar to:

   ```
   repository-root/
   ├── API_Authentication.R         # Authentication file (see below)
   ├── API_deepcyc_tcwinds_events.R # Main processing script
   ├── locations.csv                # Sample locations file
   ├── API_WaL.Rproj                # RStudio project file (sets working directory)
   ├── README.md                    # This file
   ```

5. **Configure Your Environment:**

   - **Authentication:**  
     Open `API_Authentication.R` and replace the placeholder `"username"` and `"password"` with your actual API credentials.  
          
   - **Adjust Parameters:**  
     Open **API_deepcyc_tcwinds_events.R** and review the **User Input Parameterisation** section. Adjust parameters such as:
     - `product_version`
     - Hazard parameters: Wind speed units, terrain correction, averaging period, and threshold

---

## Running the Code

1. **Open the Project:**  
   In RStudio, open the `.Rproj` file from the repository root. This automatically sets the working directory.
   
2. **Run the Main Script:**  
   Execute the **API_deepcyc_tcwinds_events.R** script to process the data. The script will:
   - Load location data from `locations.csv`
   - Authenticate with the API
   - Retrieve data for each location
   - Apply filtering and construct a pivot table
   - Save outputs as CSV and Parquet files

3. **Review Output:**  
   The processed files (e.g., `deepcyc_tcwind_events_pivot.csv`) will be saved in the repository folder. Open them with your preferred software to review the results.

---

## API Access and Authentication

- **API Access:**  
  To use the Reask API, you must have the appropriate access rights.  
  Refer to the [API Swagger Documentation](https://api.reask.earth/v2/docs) for a full list of parameters and further details.  
  If access is restricted, contact your administrator or follow the necessary steps to obtain API credentials.

- **Authentication File (`API_Authentication.R`):**  
  This file sends a POST request to the Reask token endpoint, retrieves an access token, and sets up the necessary headers. Make sure to update this file with your actual credentials.

---

## Contributing

Feel free to fork the repository and submit pull requests if you have improvements or bug fixes. Please follow standard GitHub contribution guidelines. **Important:** Do not include your personal API credentials in your commits or pull requests. If you need to update the authentication file, use placeholder values (e.g., "username" and "password") or a separate template file (e.g., `API_Authentication_template.R`) so that sensitive information is not exposed.

---

## License

Include license information here if applicable.

---

By following these instructions, you should be able to run the code on your machine with minimal adjustments. The repository is organized to be generic—simply clone or download, update the credentials and parameters, and run the script.

---
