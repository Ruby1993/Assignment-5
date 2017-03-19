# Assignment-5
## Company Strategy Analysis
The CEO has charged your analytics groups with a task: “What are the characteristics of an organization that adapts well to data analytics?” The CEO’s intention is to restructure the company to foster adoption and advancement of data analytics capabilities across units.
* Text Analysis
  - A. Data Collection
Based on the Forbes data company ranking list in 2015, using google search to get the mission statements and core values of well-performed companies in the list, which are saved as company_corevalu.csv /company_mission.csv, and represented below,
  - B. Dataset Input and Description
  - C. Text Analysis
    - Text Preprocessing
      - Initializing corpus
      - Cleaning corpus&Separate sentence&Remove the stop words
    - Result analysis on single word frequency
    Based on the results in the last part and most frequent words displayed above, we could get some ideas,
      - In the mission statement file, except the directly related words with the big data companies(“data””analytics””business””mission”), we could get there are other frequent meaningful words including “people”, “customer”, “world”, which means in general the companies are focusing on the people, and seems try to serve the customers in the world. At the same time, there are positive words to express the companies attitude, such as “can””make””help””improve”. Also, we could see those well-performed data company have a trend to be the big name company as the big name company more prefer to have a broad mission statement. On the other hand, there are some common strategy words appeared like “enterprise”,”intelligence”,”power”,”sales”,”transform”, compared with the detailed techonology words, such as “software”, “real-time”, “cloud”,’’hadhoop”, which means there are still some startup companies focusing on the specific mission statement.
      - In the core values file, “data”,”analytics”,”business” also appeared in the top of word frequency list. We could see “platform”, “hadoop”, “intelligence”, “apache”,”real-time” all those technology word occurred.
    - Additional frequency results 
        a. Two-word Frequency
Analysis: In this results, as the dataset is not that enough and little confused in the core values and mission statement, we could see except the big data, the most frequent meaningful words are customer success, advanced analytics, work hard, business intelligence, success committed, which to some extent reflect the company’s core value and mission statement.
