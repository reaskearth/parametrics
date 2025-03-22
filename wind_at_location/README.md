# Reask API Wind At Location Data

This repository contains R scripts that retrieve location-level wind event data via the Reask API, process the CSV responses to extract key metrics, construct a pivot table, and save the results in CSV and Parquet formats. The repository also includes a sample authentication file and a sample `locations.csv` file.

---

## Overview

- **Main Script:** Retrieves data from the Reask API, applies filtering, and builds a pivot table.
- **API_Authentication.R:** Authenticates with the Reask API using your credentials and sets up request headers.
- **locations.csv:** A sample CSV file containing location data (latitude, longitude, and an ID). Modify this file with your actual locations.
- **Output Files:** The processed results are saved as CSV and Parquet files.

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

1. **Clone or Download the Repository:**

   - **Clone:**  
     Open your terminal or command prompt and run:
     ```bash
     git clone https://github.com/yourusername/repository-name.git
     ```
     This creates a local copy of the repository.

   - **Download:**  
     Alternatively, click the **"Download ZIP"** button on the GitHub repository page, unzip the folder, and open it in your RStudio.

2. **Project Structure:**

   ```
   repository-root/
   ├── API_Authentication.R         # Authentication file (see below)
   ├── locations.csv                # Sample locations file
   ├── main_script.R                # Main processing script (your code)
   ├── README.md                    # This file
   └── (other files/folders as needed)
   ```

3. **Configure Your Environment:**

   - **Working Directory:**  
     The scripts use relative paths with the `here` package. Ensure your working directory is set to the repository root. If using RStudio, opening the project (if a `.Rproj` file exists) will set this automatically.

   - **Authentication:**  
     Open `API_Authentication.R` and replace the placeholder `"username"` and `"password"` with your actual API credentials.  
     If your credentials are sensitive, consider adding `API_Authentication.R` to your `.gitignore` and using a template file (e.g., `API_Authentication_template.R`) for others.

4. **Adjust Parameters:**  
   Open the main script (`main_script.R`) and review the **User Input Parameterisation** section. Adjust parameters such as:
   - `product_version`
   - API URL
   - Wind speed units, terrain correction, averaging period, and threshold
   - Output file names

---

## Running the Code

1. **Open the Project:**  
   In RStudio, open the project or the main R script.

2. **Run the Main Script:**  
   Execute the script (`main_script.R`) to process the data. The script will:
   - Load location data from `locations.csv`
   - Authenticate with the API
   - Retrieve data for each location
   - Apply filtering and construct a pivot table
   - Save outputs as CSV and Parquet files

3. **Review Output:**  
   The processed files (e.g., `deepcyc_tcwind_events_pivot.csv`) will be saved in the repository folder. Open them in your preferred software to review the results.

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

Feel free to fork the repository and submit pull requests if you have improvements or bug fixes. Please follow standard GitHub contribution guidelines.

---

## License

Include license information here if applicable.

---

By following these instructions, you should be able to run the code on your machine with minimal adjustments. The repository is organized to be generic—simply clone or download, update the credentials and parameters, and run the script.
