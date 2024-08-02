#IMO ONL based stats

This is a template for an ONL topology that will use Telemetry. 

For Dashboards to just work, envoy configuration yamls should include the following, using the tag_name "envoy" 
is the key and making sure NODE_ID is unique to the node

stats_config:
  stats_tags:
  - tag_name: envoy
    fixed_value: $NODE_ID 

Create an ONL topology, reserve and commit it. 

#Prometheus configuration
modifiy prometheus_otel.yml otlp section updating static_configs with the ip address of the stats machine

#start stats component
Continue once everything is up and running in ONL (stats_host is the onl name e.g. h1x1)
run ./run_all_stats.sh <username> <stats_host>

You may have some trouble if you are monitoring Prometheus and/or Jaeger from other sources 
since those ports may already be in use. 

#set up Grafana add data sources
Run the Grafana locally on the machine you will be using your browser on
In your browser, go to http://localhost:3000 
You will see a login page. If this is your first time, username and password are admin
You will be prompted for a password reset 

#set up tunnels for Jaeger and Prometheus to your browser machine
create 2 tunnels to the stats_machine that has been allocated to your experiment. This should be the 
name of the physical machine, e.g. pc2core01
1) For Prometheus, tunnel ssh onl.wustl.edu -L 16686:<stats_machine>:16686
2) For Jaeger, tunnel ssh onl.wustl.edu -L 4317:<stats_machine>:4317

#add data sources in Grafana
Once logged into Grafana, select Connections from the main menu and click on DataSources
1) Add datasource "Prometheus", set the url to http://localhost:16686, select "save & test" (or host.docker.internal:16686)
2) Add datasource "Jaeger", set the url to http://localhost:9090, select "save & test" (or host.docker.internal:9090)

#load dashboards
Select Dashboards from main menu
Under New, Select Import
For each of the Dashboard json files in ../Dashboards
1) Select file for Upload
2) Set the Data Sources, for Prometheus and Jaeger choose the defaults you setup earlier
3) Click Import

Each dashboard should have a menu that lists the available imo Dashboards. 
General - gives basic status info for nodes and view of traffic
Controller - gives rudimentary stats for the envoy xds controller
HTTP - gives general stats including the tracing
HTTP2 - gives what I think are http2 specific stats
TCP & UDP - give stats related to those protocols for those types of listeners

#when running
Choose the "General" Dashboard it will have a menu for all of the related dashboards
dashboard updates every 5s. 

#how to view tracing on the HTTP Dashboard
Initially, the "Traces" Panel will not show traces for http requests. You will need to Edit the panel. 
Select Edit. In the Query A panel, select Query Type: Search. Then using the Service Name pull down menu 
select one of the nodes in your flow. If you don't see any of the nodes in the Service Name menu, this 
could mean either you don't have tracing on in the envoy configuration or the traffic is not actually 
passing through the nodes.

Once you have selected a node for tracing, select apply and return to the HTTP Dashboard. On the next refresh, 
you should see a box for each http request. To view the traces, select Explore from the panel. This will give 
you a list of traces. To explore the traces click on the TraceId of the trace. The trace information appears 
on the right.

#saving changes to dashboards
1)Saving - saves the current dashboard settings. This will be saved to the cache so that each time you login 
you will get these changes. However, if your cache gets wiped so will all of the dashboards you changed or loaded. 
For more permanent saving and sharing dashboards with others, you need to Export the Dashboard. You may save 
the dashboard via the disk icon at the top of the page. It will also prompt you any time you try to leave a page 
with changes. Note: if you happen to be looking at a particular time interval and you save it will save the time 
interval and you'll have to reset the automatic updating.

2)Exporting - exports the dashboard to a json file for sharing. To export, click the share button, select Export 
and select 'Export for sharing externally', then 'Save to file' Once saved you can load the file as described 
above. 

#adding new dashboards
If you create a new dashboard that you want to automatically link into the menus in the other "imo" dashboards, add the tags 'imo' and 'protocol' to the new dashboard. To add tags, select the settings icon (the gear), in the Tags box type the tag to add and click 'Add', then click the 'Save dashboard' button. You'll need to Export it if you want to share or import it later.

