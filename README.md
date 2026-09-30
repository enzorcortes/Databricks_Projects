# 🧱 Databricks Projects

Welcome! Here you will find insightful and creative ways to interpret data using a powerful AI-powered software used in many data analytical environments around the workforce known as 🧱 [Databricks](https://www.databricks.com). 

# Projects

## 🎬 Movies on Streaming Platforms

📁🔗 [Movies on Streaming Platforms, project files](https://github.com/enzorcortes/Databricks_Projects/tree/main/moviesonstreamingplatforms)

🎛️🔗 [Movies on Streaming Platforms, AI/BI Dashboard](https://dbc-4b6fd519-190f.cloud.databricks.com/dashboardsv3/01f1bb921924137d9361d64edd089231/published?o=7474655006789075)

🧞‍♂️🔗 [Movies on Streaming Platform, Genie Space (AI Agent)](https://dbc-4b6fd519-190f.cloud.databricks.com/genie/rooms/01f1bb9219541440ae851b68b9eeacd6?o=7474655006789075)

### Use Case

This project enables **self-service analytics** for movie streaming data, allowing business users and analysts to:
- 📊 Explore 9,500+ movies across Netflix, Hulu, Prime Video, and Disney+
- 🤖 Ask natural language questions without writing SQL
- 📈 Monitor key metrics: platform coverage, ratings, release trends, and age distributions
- 🔍 Filter and drill down into specific platforms or time periods

**Target Audience**: Data analysts, business users, and anyone learning Databricks AI/BI capabilities.

### Dataset

- **Source**: CSV file containing movie metadata from major streaming platforms
- **Size**: 9,515 movies
- **Platforms**: Netflix, Hulu, Prime Video, Disney+
- **Attributes**: Title, release year, age rating, Rotten Tomatoes score, platform availability

### Key Features

✅ **Unity Catalog Governance**: Centralized metadata, RBAC-ready schema  
✅ **AI/BI Dashboard**: 8 interactive widgets with platform filtering  
✅ **Genie Space**: Natural language Q&A over 5 tables/views  
✅ **Serverless Compute**: Zero cluster management on Free Edition  
✅ **Lightweight Semantic Layer**: SQL views for reusable business logic  
✅ **Visual Accessibility**: Check marks (✓/✗) for platform availability

### Agent Architecture:

```mermaid
flowchart TB
    %% User Layer
    User[👤 User]
    
    %% Application Layer
    Genie[🤖 Genie Space<br/>Natural Language Q&A<br/>SQL Generation<br/>Business Instructions]
    Dashboard[📊 AI/BI Dashboard<br/>Interactive Visualizations<br/>8 Widgets + 5 Datasets]
    
    %% Compute Layer
    Warehouse[⚡ Serverless Compute<br/>SQL Warehouse 2X-Small]
    
    %% Data Layer - Unity Catalog
    subgraph UC["🗄️ Unity Catalog: workspace.default"]
        direction TB
        RawTable["📦 movies_on_streaming_platforms_raw<br/>(Original CSV data)"]
        CleanTable["✅ movies_on_streaming_platforms<br/>(Cleaned, typed, documented)"]
        
        subgraph Views["📋 Analytical Views"]
            V1["v_platform_summary<br/>(Counts + Avg Scores)"]
            V2["v_movies_by_year<br/>(Release year trends)"]
            V3["v_age_rating_distribution<br/>(Rating breakdown)"]
            V4["v_top_rated_movies<br/>(Top 20 by RT score)"]
        end
        
        RawTable --> CleanTable
        CleanTable --> Views
    end
    
    %% Dashboard Data Flow
    subgraph DashData["📦 Dashboard Datasets"]
        DS1[datasets/total_movies]
        DS2[datasets/platform_summary]
        DS3[datasets/movies_by_year]
        DS4[datasets/age_rating_distribution]
        DS5[datasets/top_rated_movies]
    end
    
    subgraph Widgets["🎨 Dashboard Widgets"]
        W1[Total Movies Counter]
        W2[Movies by Platform Bar]
        W3[Avg RT Score Bar]
        W4[Movies Per Year Line + Toggle]
        W5[Age Distribution Stacked Bar]
        W6[Top 20 Table]
        W7[Platform Filter]
        W8[View Toggle]
    end
    
    %% Connections
    User -->|"Natural language<br/>question"| Genie
    User -->|"Click & explore"| Dashboard
    
    Genie -->|"Generated SQL"| Warehouse
    Dashboard -->|"Widget queries"| Warehouse
    
    Warehouse -->|"Query execution"| UC
    
    Views -->|"Feed data"| DashData
    DashData -->|"Bind to"| Widgets
    
    Warehouse -->|"Results"| Genie
    Warehouse -->|"Results"| Dashboard
    
    Genie -->|"Natural language<br/>response"| User
    Dashboard -->|"Visual insights"| User
    
    %% Styling
    classDef userStyle fill:#e1f5ff,stroke:#0288d1,stroke-width:3px
    classDef appStyle fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef computeStyle fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef dataStyle fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    classDef viewStyle fill:#c8e6c9,stroke:#388e3c,stroke-width:1px
    
    class User userStyle
    class Genie,Dashboard appStyle
    class Warehouse computeStyle
    class CleanTable,RawTable dataStyle
    class V1,V2,V3,V4 viewStyle
```
### Diagram Key

### Components
- 👤 **User**: End users interacting with Genie or Dashboard
- 🤖 **Genie Space**: Natural language Q&A agent
- 📊 **Dashboard**: Interactive visualizations and KPIs
- ⚡ **Compute**: Serverless SQL Warehouse (Free Edition)
- 🗄️ **Unity Catalog**: Data governance and storage layer
- 📋 **Views**: Analytical views serving as lightweight semantic layer

### Data Flow
1. User asks question → Genie generates SQL → Warehouse executes
2. User explores dashboard → Widget queries → Warehouse executes
3. All queries hit Unity Catalog tables/views
4. Results flow back to user via Genie (text) or Dashboard (visuals)

### Color Coding
- **Blue** (User): External interaction layer
- **Orange** (Applications): Genie Space + AI/BI Dashboard
- **Purple** (Compute): Serverless SQL Warehouse
- **Green** (Data): Unity Catalog tables and views
---
