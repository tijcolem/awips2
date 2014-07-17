<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
response.setHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-cache");
response.setDateHeader("Expires", 0);
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>ASCII Request</title>
<STYLE TYPE="text/css">
h1    {text-align:center}
table {background-color:silver;border-style:solid;border-color:black;border-width:1}
td    {background-color:white;border-style:solid;border-color:black;border-width:1}
th    {background-color:white;border-style:solid;border-color:black;border-width:1}
</STYLE>
</head>
<body>
<table align=center>
<TR><TD><img src="rayAWIPS.jpg" align=middle></TD>
<TD><H1 style="font-align:center;">
&mu;Engine Demonstration<BR>
JScript Script Runner<BR>
Create Wind Speed Chart</H1>
<TD><img src="rayAWIPS.jpg" align=middle></TD></TR>
<TR><TD COLSPAN=3>
<CENTER>
This script creates a Wind Speed Chart from a multiple GRIB retrieval.<BR>
This page uses <em>GribWind.js</em> and <em>GribImage.js</em> from the script library.
</CENTER></TD>

</TD></TR>
</table>

<form method=post action="runAction.jas">
<input type=hidden name=requesttype value=javascript>
<input type=hidden name=sortby value=timeobs>
<table align=center>
<tr><td colspan=2>
<textarea name="actionXML" cols="80" rows="22" style="background-color:aqua">
/* the compact action script */
include("GribWinds.js");
include("GribImage.js");

/* Define the class to perform the analysis */
function WindSpeedImage() {
  /* names of things */
  this.grib = "grib";
  this.obs = "obs";
  /* query objects */
  this.gQuery = new GribWinds(this.grib,true);
  /* the image creator */
  this.iMaker = new GribImage(this.grib);
  /* the logger */
  this.logger = new SystemLog();
}

function _execute() {
  var response;
  /* get the wind speed as a grib */
  var wResult = this.gQuery.execute();
  if (wResult.getClass().getSimpleName() != "FloatDataRecord") {
    this.logger.log("warn","GRIB Winds creation failed.");
    return wResult;
  }
  this.logger.log("info","GRIB Winds creation successful.");
  var geom = this.gQuery.getGeom();
  var crs = this.gQuery.getCRS();

  /* create the derived image */
  this.iMaker.setGrid(wResult);
  this.iMaker.setCrs(crs);
  this.iMaker.setGeom(geom);
  var imageOut = this.iMaker.execute();
  geom = this.iMaker.getGeom();
  var format = this.iMaker.getFormat();
  
  /* write the image to the file and return the response */
  var fileOut = new FileOut(imageOut, format);
  var writeFile = fileOut.execute();
  var makeResponse = new MakeResponseUri(writeFile, 
                                         null, 
                                         this.gQuery.getDataURI(), 
                                         this.format);
  return makeResponse.execute();  
}

/* helper methods */
function _makeError(message,query) {
   var response = new MakeResponseNull(message,query);
   return response.execute();
}

/* setters for query objects */
function _addParameter(name,value) {
  this.gQuery.addParameter(name,value);
}
function _addList(name,value) {
  this.gQuery.addParameter(name,value,"in");
}
function _setSortValue(sortValue) {
  this.gQuery.setSortby(sortValue);
}
function _setCount(count) {
  this.gQuery.setCount(count);
}
/* setters for image creation parameters */
function _setScaleFactor(scale) {
  this.iMaker.setScaleFactor(scale);
}

function _reprojectImage(reproject) {
  this.iMaker.setReproject(reproject);
}

function _setColorMap(colormap){
  this.iMaker.setColormap(colormap);
}

function _setFormat(format){
  this.iMaker.setFormat(format);
}

/* mapping functions to the object */
WindSpeedImage.prototype.execute = _execute;
WindSpeedImage.prototype.addParameter = _addParameter;
WindSpeedImage.prototype.addList = _addList;
WindSpeedImage.prototype.setSortValue = _setSortValue;
WindSpeedImage.prototype.setCount = _setCount;
WindSpeedImage.prototype.setScaleFactor = _setScaleFactor;
WindSpeedImage.prototype.reprojectImage = _reprojectImage;
WindSpeedImage.prototype.setColorMap = _setColorMap;
WindSpeedImage.prototype.setFormat = _setFormat;
WindSpeedImage.prototype.makeError = _makeError;

var runner = new WindSpeedImage();
/* setup the basic grib queries */
runner.addParameter("levelinfo","10.0_m");
runner.addParameter("forecasttime","0");
runner.addParameter("gridid",212);
runner.setSortValue("basetime");
runner.setCount(1);
/* set image properties */
runner.setColorMap("GribRGB");
runner.setFormat("png");
runner.setScaleFactor(3.0);
/* execute the script */
runner.execute();




</textarea>
</td></tr>
<tr><th colspan=2><em>Enter Values for Message</em></th></tr> 

<tr><td><B>Name:</B></td>
<td><input type=text name=name value="JS Request"></td></tr>

</td></td>
<tr><td><B>Action:</B></td><td>
<input type=radio name=function value=validate disabled>Validate
<input type=radio name=function value=subscribe disabled>Subscribe
<input type=radio name=function value=execute checked>Execute</tr>
</td></tr></table>
<br>
<div align=center>
<input type="submit" value="Get Report">
<input type=reset>
Timeout:
<select name=receiveTime>
   <option value=60000 selected>1 minute
   <option value=120000>2 minutes
   <option value=180000>3 minutes
   <option value=240000>4 minutes
   <option value=300000>5 minutes
   <option value=360000>6 minutes
   <option value=420000>7 minutes
   <option value=480000>8 minutes
   <option value=540000>9 minutes
   <option value=600000>10 minutes
</select>
</div>
</form>
</body>
</html>