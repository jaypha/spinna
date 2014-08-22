/*
 * Date picker.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

var uniqID = {
   counter:0,
   get:function(prefix) {
       if(!prefix) {
           prefix = "uniqid";
       }
       var id =  prefix+""+uniqID.counter++;
       if(jQuery("#"+id).length == 0)
           return id;
       else
           return uniqID.get()
 
   }
}

function is_leap_year(year)
{
  if (year%100 == 0)
    return year%400 == 0;
  else
    return year%4 == 0;
}


var calendars = {};

function Calendar()
{
  this.id = uniqID.get("calendar");

  calendars[this.id] = this;
  $("body").append($("<div class='calendar-box' id='"+this.id+"'></div>"));
  this.cal = $('#'+this.id);
  //this.w = w;
  //this.p = p;
  //var t = this;
  //p.focus(function(){t.go()});
  //p.blur(function(){t.hide()});
  //w.click(function(){t.go()});
}

Calendar.labels =
{
  months : ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],
  days : [ "S", "M", "T", "W", "T", "F", "S" ],
  cancel : "Cancel",
  clear : "Clear",
  prev: "&#9668;",
  next: "&#9658;"
}

Calendar.day_classes = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"];
Calendar.month_days = [31,28,31,30,31,30,31,31,30,31,30,31];

/*
Calendar.prototype.go = function()
{
  $(".calendar-box").hide();

  // TODO check for date validity.
  var v = this.w.val();
  if (v != "")
    v = new Date(v.replace(/-/g,'/'));
  else
    v = null;
  this.show_calendar(get_position(this.p.get(0)), v);
}
*/
// pos : [x,y] position array
// date : date object

Calendar.prototype.show = function(pos, date)
{
  this.cal.css("left", pos[0]+"px");
  this.cal.css("top", pos[1]+"px");

  this.curdate = date;
  this.today = new Date();

  if (date !== null)
    this.make_calendar(date.getFullYear(), date.getMonth());
  else
    this.make_calendar(this.today.getFullYear(), this.today.getMonth());

  this.cal.show();
}

Calendar.prototype.make_calendar = function(year, month)
{
  year = parseInt(year);
  month = parseInt(month);
  var cur_day = 0;
  var to_day  = 0;

  if
  ( 
    this.curdate !== null &&
    year == this.curdate.getFullYear() &&
    month == this.curdate.getMonth()
  )
  {
    cur_day = this.curdate.getDate();
  }

  if (year == this.today.getFullYear() && month == this.today.getMonth())
    to_day = this.today.getDate();

  //Display the table
  var next_month = month+1;
  var next_month_year = year;
  if(next_month>=12) {
    next_month = 0;
    next_month_year++;
  }
  
  var previous_month = month-1;
  var previous_month_year = year;
  if(previous_month< 0) {
    previous_month = 11;
    previous_month_year--;
  }

  var html = [];

  html.push("<table>");
  html.push("<tr><th><a href='javascript:calendars[\""+this.id+"\"].make_calendar("+(previous_month_year)+","+(previous_month)+");' title='"+Calendar.labels.months[previous_month]+" "+(previous_month_year)+"'>"+Calendar.labels.prev+"</a></th>");
  html.push("<th colspan='5' class='calendar-title'><select name='calendar-month' class='calendar-month' onChange='calendars[\""+this.id+"\"].make_calendar("+year+",this.value);'>");
  for(var i in Calendar.labels.months) {
    html.push("<option value='"+i+"'");
    if(i == month) html.push(" selected='selected'");
    html.push(">"+Calendar.labels.months[i]+"</option>");
  }
  html.push("</select>");
  html.push("<select name='calendar-year' class='calendar-year' onChange='calendars[\""+this.id+"\"].make_calendar(this.value, "+month+");'>");
  var current_year = this.today.getFullYear();
  
  for(var i=current_year-70; i<current_year+10; i++) {
    html.push("<option value='"+i+"'")
    if(i == year) html.push(" selected='selected'");
    html.push(">"+i+"</option>");
  }
  html.push("</select></th>");
  html.push("<th><a href='javascript:calendars[\""+this.id+"\"].make_calendar("+(next_month_year)+","+(next_month)+");' title='"+Calendar.labels.months[next_month]+" "+(next_month_year)+"'>"+Calendar.labels.next+"</a></th></tr>");
  html.push("<tr class='header'>");
  for(var weekday=0; weekday<7; weekday++) html.push("<td>"+Calendar.labels.days[weekday]+"</td>");
  html.push("</tr>");
  
  //Get the first day of this month
  var first_day = new Date(year,month,1);
  first_day.setFullYear(year);

  var start_day = first_day.getDay();
  
  var d = 1;
  var flag = 0;
  
  var days_in_this_month = Calendar.month_days[month];

  //Leap year support
  if (month == 1 && is_leap_year(year))
    days_in_this_month = 29;

  //Create the calender
  for(var i=0;i<=5;i++) {
    //if(w >= days_in_this_month) break;
    html.push("<tr>");
    for(var j=0;j<7;j++) {
      if(d > days_in_this_month) flag=0; //If the days has overshooted the number of days in this month, stop writing
      else if(j >= start_day && !flag) flag=1;//If the first day of this month has come, start the date writing

      if(flag) {
        var w = d, mon = month+1;
        //if(w < 10)	w	= "0" + w;

        var class_name = Calendar.day_classes[j];
        if(cur_day == d) class_name += " selected";
        else if (to_day == d) class_name += " today";
        
        html.push("<td class='days "+class_name+"'><a href='javascript:calendar_select(\""+this.id+"\","+year+","+month+","+d+");'>"+w+"</a></td>");
        d++;
      } else {
        html.push("<td class='days'>&nbsp;</td>");
      }
    }
    html.push("</tr>");
  }
  html.push("</table>");
  html.push("<button type='button' class='calendar-cancel' onclick='calendars[\""+this.id+"\"].clear(); calendars[\""+this.id+"\"].hide();' >"+Calendar.labels.clear+"</button>");
  html.push("<button type='button' class='calendar-cancel' onclick='calendars[\""+this.id+"\"].hide();' >"+Calendar.labels.cancel+"</button>");

  this.cal.html(html.join(""));
}

Calendar.prototype.select = function(year,mon,day)
{
  var date = new Date(year,mon,day);
  date.setFullYear(year);
  this.on_select(date);
}

Calendar.prototype.clear = function()
{
  this.on_select(null);
}

Calendar.prototype.hide = function()
{
  this.cal.hide();
}

function calendar_select(cal,year,month,day)
{
  calendars[cal].select(year,month,day); calendars[cal].hide();
}

function get_position(ele)
{
  ele = ele.get(0);
  var x = 0;
  var y = 0;
  while (ele) {
    x += ele.offsetLeft;
    y += ele.offsetTop;
    ele = ele.offsetParent;
  }
  if (navigator.userAgent.indexOf("Mac") != -1 && typeof document.body.leftMargin != "undefined") {
    x += document.body.leftMargin;
    offsetTop += document.body.topMargin;
  }

  var xy = new Array(x,y);
  return xy;
}
