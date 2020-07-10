# Python Service Bureau Automated Mode Choice Documented (IN PROGRESS)

**Required Software**: SQL Server Management Studio (SMSS), Anaconda

1. In SQL Server Management Studio, connect to the server titled sql2014a8. Then, go into the LoadMgraList.sql file (```T:\ABM\SB\Template\Analysis\ModeChoice\sql```). Update the ```FROM``` statement to the appropriate project MGRA list and execute the script. For the purpose of this documentation, I’ll be using the NAVWAR MGRA List. ```\\nasb8\transdata\projects\sr13\OWP\GCS2\Analysis\NAVWAR_mgra_list.csv```

2. Copy the ModeChoice Python folder (```T:\ABM\SB\Template\Analysis\ModeChoice\Python\python```) to a secure location (i.e. a new project folder). For the purposes of this documentation, I will use my desktop.

3. Open the Anaconda Prompt.

4. In the Anaconda prompt, change the directory to the copied ModeChoice folder in the secure location (see step 2). For example, since I put the ModeChoice folder on my desktop, I’ll use the following command: CD C:\Users\3LetterSANDAGName\Desktop\python

5. Create the Python environment by typing the following: ```conda env create -f environment.yml``` (Ignore the warning below because I have already created the environment on a previous test).

6. Activate the Python environment by typing ```conda activate sb```

7. Run the Python process by typing ```main.py```

8. The process will then ask you for a scenario ID. For the purpose of this documentation, we will use Scenario ID 1205.

9. The process will then ask you to enter a scenario header, report geography, and report file name summary. For the purpose of this documentation, I will call them all Test3. The process should take about 10 minutes to run.

10. After running, a new Excel workbook will be written to the local ModeChoice Python folder. The process will overwrite any existing workbooks that have already been created in the project folder with the same naming convention.

**Note**: The template path and report write path can both be changed in the settings.py file. 
  * template_path: ```T:/ABM/SB/Template/Analysis/ModeChoice/Mode_Choice_Template.xlsx```
  * report_write_path:  ```./Mode_Choice```

