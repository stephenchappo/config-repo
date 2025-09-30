# Cline & MCP Tools Inventory

This document lists the primary tools available to Cline and any connected MCP servers, focused on Cline/MCP capabilities.

## Core Cline Tools
- execute_command: Run shell commands on your machine  
- read_file: Read the contents of a file  
- write_to_file: Create or overwrite a file with complete content  
- replace_in_file: Perform precise SEARCH/REPLACE edits in a file  
- search_files: Regex search across files with contextual results  
- list_files: List files and directories (optionally recursive)  
- list_code_definition_names: Enumerate top-level definitions in source code  
- browser_action: Control a headless browser for UI testing or verification  
- use_mcp_tool: Invoke a tool provided by a connected MCP server  
- access_mcp_resource: Retrieve a data resource from an MCP server  
- ask_followup_question: Prompt the user for clarification or choices  
- attempt_completion: Present final results once all steps are confirmed  
- new_task: Summarize context and create a new task for continued work  
- plan_mode_respond: Draft plans in Plan Mode before implementation  
- load_mcp_documentation: Load MCP server creation documentation  

## Installed MCP Tools
git

## Available & Popular MCP Tools
- github.com/modelcontextprotocol/servers/.../github  
  *Tool*: create_issue, list_repos, add_labels  
  *Use case*: Automate issue tracking and repository management directly from chat.  
- weather-server  
  *Tool*: get_forecast(city, days)  
  *Use case*: Quickly retrieve local weather data for scheduling or environment checks.  
- docker-server  
  *Tool*: list_containers, start_container, stop_container  
  *Use case*: Manage Docker containers (Radarr, Whisparr, Prowlarr) without leaving the chat.  
- translation-server  
  *Tool*: translate_text(text, target_language)  
  *Use case*: Internationalize documentation and code comments for multilingual teams.  
- calendar-server  
  *Tool*: create_event(date, time, description)  
  *Use case*: Schedule reminders or meetings related to development tasks.  

## Usage Notes
- Structure files in `/memory-bank` with numeric prefixes to control sort order.  
- Keep this list focused on Cline/MCP tools; host CLI references are invoked via execute_command.
