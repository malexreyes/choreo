//https://ballerina.io/learn/by-example/graphql-graphiql/

import ballerina/graphql;
//import ballerina/http;
import ballerina/sql;
import ballerinax/aws.redshift; // Get the AWS Redshift connector
import ballerinax/aws.redshift.driver as _; // Get the AWS Redshift driver
// Connection Configurations

configurable string jdbcUrl = ?;
configurable string user = ?;
configurable string password = ?;
 
// Initialize the Redshift client
redshift:Client dbClient = check new (jdbcUrl, user, password);

@graphql:ServiceConfig {
    graphiql: {
        enabled: true
    }
}

service on new graphql:Listener(9090) {

    resource function get category() returns Category[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Category limit 10`;
        stream<Category, error?> resultStream = dbClient->query(sqlQuery);
        return check from Category category in resultStream
        select category;
    }

    //resource function post category(@http:Payload Category cat) returns error? {
      // _ =  check dbClient->execute(`INSERT INTO Category (catid, catname) VALUES (${cat.catid}, ${cat.catname});`);
    //}
    remote function addBook(string catid, string catname) returns int|error {
        sql:ExecutionResult result = check dbClient->execute(`INSERT INTO Category (catid, catname) VALUES (${catid}, ${catname});`);
        return <int>result.lastInsertId;
    }

    resource function get date() returns Date[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Date limit 10`;
        stream<Date, error?> resultStream = dbClient->query(sqlQuery);
        return check from Date date in resultStream
        select date;
    }

    resource function get event() returns Event[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Event limit 10`;
        stream<Event, error?> resultStream = dbClient->query(sqlQuery);
        return check from Event event in resultStream
        select event;
    }

    resource function get venue() returns Venue[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Venue limit 10`;
        stream<Venue, error?> resultStream = dbClient->query(sqlQuery);
        return check from Venue venue in resultStream
        select venue;
    }

    resource function get users() returns Users[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Users limit 10`;
        stream<Users, error?> resultStream = dbClient->query(sqlQuery);
        return check from Users users in resultStream
        select users;
    }

    resource function get listings() returns Listing[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Listing limit 10`;
        stream<Listing, error?> resultStream = dbClient->query(sqlQuery);
        return check from Listing listing in resultStream
        select listing;
    }


    resource function get listing/sales() returns Listing[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Listing l 
                                            left join Sales s on l.listid = s.listid 
                                            limit 10`;
        stream<Listing, error?> resultStream = dbClient->query(sqlQuery);
        return check from Listing listing in resultStream
        select listing;
    }

    resource function get sales(int? salesid) returns Sales[]|error {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Sales s`;
        if salesid is int {
            sqlQuery = sql:queryConcat(sqlQuery, ` where s.salesid=${salesid}`);
        }
        
        sqlQuery = sql:queryConcat(sqlQuery, ` limit 10`);
        stream<Sales, error?> resultStream = dbClient->query(sqlQuery);
        return check from Sales sales in resultStream
        select sales;
    }

    //public function findCountriesByHighestNoOfDeaths(table<Sales> dataTable, int n) returns [string, decimal][] {
        //[string, decimal][] countriesWithDeaths = from Sales entry in dataTable
          //  order by entry.salesid descending
            //limit n
            //select entry.salesid;
        //return countriesWithDeaths;
    //}

    //resource function get sales/category() returns Sales[]|error {
        //sql:ParameterizedQuery sqlQuery = `SELECT * FROM Sales where   limit 10`;
        //stream<Sales, error?> resultStream = dbClient->query(sqlQuery);
        //return check from Sales sales in resultStream
        //select sales;
    //}
}

type Category record {|
    @graphql:ID int catid;
    string catgroup;
    string catname;
    string catdesc;

|};

type Date record {|
    @graphql:ID int dateid;
    string caldate;
    string day;
    int week;
    string month;
    string qtr;
    int year;
    boolean holiday;
|};

type Event record {|
    @graphql:ID int eventid;
    int venueid;
    int catid;
    int dateid;
    string eventname;
    string starttime;
|};

type Venue record {|
    @graphql:ID int venueid;
    int venuename;
    int venuecity;
    int venuestate;
    string venueseats;
|};

type Users record {|
    @graphql:ID int userid;
    string username;
    string firstname;
    string lastname;
    string city;
    string state;
    string email;
    string phone;
    boolean likesports;
|};

type Listing record {|
    @graphql:ID int listid;
    int sellerid;
    int eventid;
    int dateid;
    int numtickets;
    string priceperticket;
    string totalprice;
    string listtime;
|};

type Sales record {|
    @graphql:ID int salesid;
    int listid;
    int sellerid;
    int buyerid;
    int eventid;
    int dateid;
    string qtysold;
    string pricepaid;
    string commission;
    string saletime;
|};


  //type Query {
    //sales: [Sale];
    //sale(id: salesid): Sale
  //}

 