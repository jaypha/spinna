/*
 * D bindings for Maria 5.5 MySQL Client.
 *
 * By Jason den Dulk
 */

/*
   Copyright (c) 2000, 2012, Oracle and/or its affiliates.
   Copyright (c) 2012, Monty Program Ab.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA */

/*
  This file defines the client API to MySQL and also the ABI of the
  dynamically linked libmysqlclient.

  The ABI should never be changed in a released product of MySQL,
  thus you need to take great care when changing the file. In case
  the file is changed so the ABI is broken, you must also update
  the SHARED_LIB_MAJOR_VERSION in cmake/mysql_version.cmake
*/

module jaypha.dbms.mysql.c.mysql;

extern (C):


alias char my_bool;

alias int my_socket;

//#include "mysql_version.h"
//#include "mysql_com.h"

/* Shutdown/kill enums and constants */ 

/* Bits for THD::killable. */
enum MYSQL_SHUTDOWN_KILLABLE_CONNECT =   cast(ubyte)(1 << 0);
enum MYSQL_SHUTDOWN_KILLABLE_TRANS   =   cast(ubyte)(1 << 1);
enum MYSQL_SHUTDOWN_KILLABLE_LOCK_TABLE = cast(ubyte)(1 << 2);
enum MYSQL_SHUTDOWN_KILLABLE_UPDATE    =  cast(ubyte)(1 << 3);

enum mysql_enum_shutdown_level {
  /*
    We want levels to be in growing order of hardness (because we use number
    comparisons). Note that DEFAULT does not respect the growing property, but
    it's ok.
  */
  SHUTDOWN_DEFAULT = 0,
  /* wait for existing connections to finish */
  SHUTDOWN_WAIT_CONNECTIONS= MYSQL_SHUTDOWN_KILLABLE_CONNECT,
  /* wait for existing trans to finish */
  SHUTDOWN_WAIT_TRANSACTIONS= MYSQL_SHUTDOWN_KILLABLE_TRANS,
  /* wait for existing updates to finish (=> no partial MyISAM update) */
  SHUTDOWN_WAIT_UPDATES= MYSQL_SHUTDOWN_KILLABLE_UPDATE,
  /* flush InnoDB buffers and other storage engines' buffers*/
  SHUTDOWN_WAIT_ALL_BUFFERS= (MYSQL_SHUTDOWN_KILLABLE_UPDATE << 1),
  /* don't flush InnoDB buffers, flush other storage engines' buffers*/
  SHUTDOWN_WAIT_CRITICAL_BUFFERS= (MYSQL_SHUTDOWN_KILLABLE_UPDATE << 1) + 1
};

/* options for mysql_set_option */
enum enum_mysql_set_option
{
  MYSQL_OPTION_MULTI_STATEMENTS_ON,
  MYSQL_OPTION_MULTI_STATEMENTS_OFF
};

struct st_dynamic_array
{
  ubyte *buffer;
  uint elements,max_element;
  uint alloc_increment;
  uint size_of_element;
};

enum SQLSTATE_LENGTH = 5;
enum SCRAMBLE_LENGTH = 20;
enum MYSQL_ERRMSG_SIZE = 512;

enum enum_server_command
{
  COM_SLEEP, COM_QUIT, COM_INIT_DB, COM_QUERY, COM_FIELD_LIST,
  COM_CREATE_DB, COM_DROP_DB, COM_REFRESH, COM_SHUTDOWN, COM_STATISTICS,
  COM_PROCESS_INFO, COM_CONNECT, COM_PROCESS_KILL, COM_DEBUG, COM_PING,
  COM_TIME, COM_DELAYED_INSERT, COM_CHANGE_USER, COM_BINLOG_DUMP,
  COM_TABLE_DUMP, COM_CONNECT_OUT, COM_REGISTER_SLAVE,
  COM_STMT_PREPARE, COM_STMT_EXECUTE, COM_STMT_SEND_LONG_DATA, COM_STMT_CLOSE,
  COM_STMT_RESET, COM_SET_OPTION, COM_STMT_FETCH, COM_DAEMON,
  /* don't forget to update const char *command_name[] in sql_parse.cc */

  /* Must be last */
  COM_END
};

enum enum_field_types { MYSQL_TYPE_DECIMAL, MYSQL_TYPE_TINY,
			MYSQL_TYPE_SHORT,  MYSQL_TYPE_LONG,
			MYSQL_TYPE_FLOAT,  MYSQL_TYPE_DOUBLE,
			MYSQL_TYPE_NULL,   MYSQL_TYPE_TIMESTAMP,
			MYSQL_TYPE_LONGLONG,MYSQL_TYPE_INT24,
			MYSQL_TYPE_DATE,   MYSQL_TYPE_TIME,
			MYSQL_TYPE_DATETIME, MYSQL_TYPE_YEAR,
			MYSQL_TYPE_NEWDATE, MYSQL_TYPE_VARCHAR,
			MYSQL_TYPE_BIT,
                        MYSQL_TYPE_NEWDECIMAL=246,
			MYSQL_TYPE_ENUM=247,
			MYSQL_TYPE_SET=248,
			MYSQL_TYPE_TINY_BLOB=249,
			MYSQL_TYPE_MEDIUM_BLOB=250,
			MYSQL_TYPE_LONG_BLOB=251,
			MYSQL_TYPE_BLOB=252,
			MYSQL_TYPE_VAR_STRING=253,
			MYSQL_TYPE_STRING=254,
			MYSQL_TYPE_GEOMETRY=255

};

struct st_vio ;
alias st_vio Vio;

struct st_net {
  Vio *vio;
  ubyte* buff, buff_end, write_pos, read_pos;
  my_socket fd;					/* For Perl DBI/dbd */
  /*
    The following variable is set if we are doing several queries in one
    command ( as in LOAD TABLE ... FROM MASTER ),
    and do not want to confuse the client with OK at the wrong time
  */
  ulong remain_in_buf,length, buf_length, where_b;
  ulong max_packet,max_packet_size;
  uint pkt_nr,compress_pkt_nr;
  uint write_timeout, read_timeout, retry_count;
  int fcntl;
  uint *return_status;
  ubyte reading_or_writing;
  char save_char;
  char net_skip_rest_factor;
  my_bool unused1; /* Please remove with the next incompatible ABI change */
  my_bool compress;
  my_bool unused3; /* Please remove with the next incompatible ABI change. */
  /*
    Pointer to query object in query cache, do not equal NULL (0) for
    queries in cache that have not stored its results yet
  */

  /*
    Unused, please remove with the next incompatible ABI change.
  */
  ubyte *unused;
  uint last_errno;
  ubyte error; 
  my_bool unused4; /* Please remove with the next incompatible ABI change. */
  my_bool unused5; /* Please remove with the next incompatible ABI change. */
  /** Client library error message buffer. Actually belongs to struct MYSQL. */
  char last_error[MYSQL_ERRMSG_SIZE];
  /** Client library sqlstate buffer. Set along with the error message. */
  char sqlstate[SQLSTATE_LENGTH+1];
  void *extension;
}
alias st_net NET;

//#include "mysql_time.h"


struct st_list {
  st_list* prev,next;
  void *data;
}
alias st_list LIST;

alias  int function(void *,void *) list_walk_action;

LIST *list_add(LIST *root,LIST *element);
LIST *list_delete(LIST *root,LIST *element);
LIST *list_cons(void *data,LIST *root);
LIST *list_reverse(LIST *root);
void list_free(LIST *root,uint free_data);
uint list_length(LIST *);
int list_walk(LIST *,list_walk_action action,ubyte * argument);

extern uint mysql_port;
extern char *mysql_unix_port;

enum CLIENT_NET_READ_TIMEOUT	=	365*24*3600;	/* Timeout on read */
enum CLIENT_NET_WRITE_TIMEOUT	= 365*24*3600;	/* Timeout on write */

struct st_mysql_field {
  char* name;                 /* Name of column */
  char* org_name;             /* Original column name, if an alias */
  char* table;                /* Table of column if column was a field */
  char* org_table;            /* Org table name, if table was an alias */
  char* db;                   /* Database for table */
  char* catalog;	      /* Catalog for table */
  char* def;                  /* Default value (set by mysql_list_fields) */
  ulong length;       /* Width of column (create length) */
  ulong max_length;   /* Max width for selected set */
  uint name_length;
  uint org_name_length;
  uint table_length;
  uint org_table_length;
  uint db_length;
  uint catalog_length;
  uint def_length;
  uint flags;         /* Div flags */
  uint decimals;      /* Number of decimals in field */
  uint charsetnr;     /* Character set */
  enum_field_types type; /* Type of field. See mysql_com.h for types */
  void* extension;
}
alias st_mysql_field MYSQL_FIELD;

alias char** MYSQL_ROW;		/* return data as array of strings */
alias uint MYSQL_FIELD_OFFSET; /* offset to current field */

alias ulong my_ulonglong;

//#include "typelib.h"

struct st_mysql_rows {
  st_mysql_rows* next;		/* list of rows */
  MYSQL_ROW data;
  ulong length;
}
alias st_mysql_rows MYSQL_ROWS;

alias MYSQL_ROWS* MYSQL_ROW_OFFSET;	/* offset to current row */

struct st_used_mem
{				   /* struct for once_alloc (block) */
  st_used_mem *next;	   /* Next block in use */
  size_t left;                     /* memory left in block  */
  size_t size;                     /* size of block */
}
alias st_used_mem USED_MEM;


struct st_mem_root
{
  USED_MEM *free;                  /* blocks with free memory in it */
  USED_MEM *used;                  /* blocks almost without free memory */
  USED_MEM *pre_alloc;             /* preallocated block */
  /* if block have less memory it will be put in 'used' list */
  size_t min_malloc;
  size_t block_size;               /* initial block size */
  uint block_num;          /* allocated blocks counter */
  /* 
     first free block in queue test counter (if it exceed 
     MAX_BLOCK_USAGE_BEFORE_DROP block will be dropped in 'used' list)
  */
  uint first_block_usage;

  void function() error_handler;
}
alias st_mem_root MEM_ROOT;

struct st_mysql_data {
  MYSQL_ROWS* data;
  void * x;//embedded_query_result* embedded_info;
  MEM_ROOT alloc;
  my_ulonglong rows;
  uint fields;
  /* extra info for embedded library */
  void* extension;
}
alias st_mysql_data MYSQL_DATA;

enum mysql_option 
{
  MYSQL_OPT_CONNECT_TIMEOUT, MYSQL_OPT_COMPRESS, MYSQL_OPT_NAMED_PIPE,
  MYSQL_INIT_COMMAND, MYSQL_READ_DEFAULT_FILE, MYSQL_READ_DEFAULT_GROUP,
  MYSQL_SET_CHARSET_DIR, MYSQL_SET_CHARSET_NAME, MYSQL_OPT_LOCAL_INFILE,
  MYSQL_OPT_PROTOCOL, MYSQL_SHARED_MEMORY_BASE_NAME, MYSQL_OPT_READ_TIMEOUT,
  MYSQL_OPT_WRITE_TIMEOUT, MYSQL_OPT_USE_RESULT,
  MYSQL_OPT_USE_REMOTE_CONNECTION, MYSQL_OPT_USE_EMBEDDED_CONNECTION,
  MYSQL_OPT_GUESS_CONNECTION, MYSQL_SET_CLIENT_IP, MYSQL_SECURE_AUTH,
  MYSQL_REPORT_DATA_TRUNCATION, MYSQL_OPT_RECONNECT,
  MYSQL_OPT_SSL_VERIFY_SERVER_CERT, MYSQL_PLUGIN_DIR, MYSQL_DEFAULT_AUTH,
  MYSQL_ENABLE_CLEARTEXT_PLUGIN,

  /* MariaDB options */
  MYSQL_PROGRESS_CALLBACK=5999,
  MYSQL_OPT_NONBLOCK=6000
};

/**
  @todo remove the "extension", move st_mysql_options completely
  out of mysql.h
*/
struct st_mysql_options_extention; 

struct st_mysql_options {
  uint connect_timeout, read_timeout, write_timeout;
  uint port, protocol;
  ulong client_flag;
  char* host, user, password, unix_socket, db;
  st_dynamic_array *init_commands;
  char* my_cnf_file, my_cnf_group, charset_dir, charset_name;
  char* ssl_key;				/* PEM key file */
  char* ssl_cert;				/* PEM cert file */
  char* ssl_ca;					/* PEM CA file */
  char* ssl_capath;				/* PEM directory of CA-s? */
  char* ssl_cipher;				/* cipher to use */
  char* shared_memory_base_name;
  ulong max_allowed_packet;
  my_bool use_ssl;				/* if to use SSL or not */
  my_bool compress,named_pipe;
  my_bool unused1;
  my_bool unused2;
  my_bool unused3;
  my_bool unused4;
  mysql_option methods_to_use;
  char* client_ip;
  /* Refuse client connecting to server if it uses old (pre-4.1.1) protocol */
  my_bool secure_auth;
  /* 0 - never report, 1 - always report (default) */
  my_bool report_data_truncation;

  /* function pointers for local infile support */
  int function(void **, const(char)*, void *) local_infile_init;
  int function(void *, char *, uint) local_infile_read;
  void function(void *) local_infile_end;
  int function(void *, char *, uint) local_infile_error;
  void *local_infile_userdata;

  st_mysql_options_extention* extension;
};

enum mysql_status 
{
  MYSQL_STATUS_READY, MYSQL_STATUS_GET_RESULT, MYSQL_STATUS_USE_RESULT,
  MYSQL_STATUS_STATEMENT_GET_RESULT
};

enum mysql_protocol_type 
{
  MYSQL_PROTOCOL_DEFAULT, MYSQL_PROTOCOL_TCP, MYSQL_PROTOCOL_SOCKET,
  MYSQL_PROTOCOL_PIPE, MYSQL_PROTOCOL_MEMORY
};

struct character_set
{
  uint      number;     /* character set number              */
  uint      state;      /* character set state               */
  const(char)* csname;    /* collation name                    */
  const(char)* name;      /* character set name                */
  const(char)* comment;   /* comment                           */
  const(char)* dir;       /* character set directory           */
  uint      mbminlen;   /* min. length for multibyte strings */
  uint      mbmaxlen;   /* max. length for multibyte strings */
}
alias character_set MY_CHARSET_INFO;

struct st_mysql_methods;
struct charset_info_st;

struct st_mysql
{
  NET		net;			/* Communication parameters */
  ubyte* connector_fd;		/* ConnectorFd for SSL */
  char* host,user,passwd,unix_socket,server_version,host_info;
  char* info, db;
  charset_info_st* charset;
  MYSQL_FIELD* fields;
  MEM_ROOT	field_alloc;
  my_ulonglong affected_rows;
  my_ulonglong insert_id;		/* id if insert on table with NEXTNR */
  my_ulonglong extra_info;		/* Not used */
  ulong thread_id;		/* Id for connection in server */
  ulong packet_length;
  uint	port;
  ulong client_flag,server_capabilities;
  uint	protocol_version;
  uint	field_count;
  uint 	server_status;
  uint  server_language;
  uint	warning_count;
  st_mysql_options options;
  mysql_status status;
  my_bool	free_me;		/* If free in mysql_close */
  my_bool	reconnect;		/* set to 1 if automatic reconnect */

  /* session-wide random string */
  char	        scramble[SCRAMBLE_LENGTH+1];
  my_bool unused1;
  void* unused2, unused3, unused4, unused5;

  LIST* stmts;                     /* list of all statements */
  st_mysql_methods *methods;
  void *thd;
  /*
    Points to boolean flag in MYSQL_RES  or MYSQL_STMT. We set this flag 
    from mysql_stmt_close if close had to cancel result set of this object.
  */
  my_bool *unbuffered_fetch_owner;
  /* needed for embedded server - no net buffer to store the 'info' */
  char *info_buffer;
  void *extension;
}
alias st_mysql MYSQL;


struct st_mysql_res {
  my_ulonglong  row_count;
  MYSQL_FIELD	*fields;
  MYSQL_DATA	*data;
  MYSQL_ROWS	*data_cursor;
  ulong *lengths;		/* column lengths of current row */
  MYSQL		*handle;		/* for unbuffered reads */
  st_mysql_methods *methods;
  MYSQL_ROW	row;			/* If unbuffered read */
  MYSQL_ROW	current_row;		/* buffer to current row */
  MEM_ROOT	field_alloc;
  uint	field_count, current_field;
  my_bool	eof;			/* Used by mysql_fetch_row */
  /* mysql_stmt_close() had to cancel this result */
  my_bool       unbuffered_fetch_cancelled;  
  void *extension;
}
alias st_mysql_res MYSQL_RES;

struct st_mysql_parameters
{
  ulong *p_max_allowed_packet;
  ulong *p_net_buffer_length;
  void *extension;
}
alias st_mysql_parameters MYSQL_PARAMETERS;

/*
  Flag bits, the asynchronous methods return a combination of these ORed
  together to let the application know when to resume the suspended operation.
*/

/*
  Wait for data to be available on socket to read.
  mysql_get_socket_fd() will return socket descriptor.
*/
enum MYSQL_WAIT_READ = 1;
/* Wait for socket to be ready to write data. */
enum MYSQL_WAIT_WRITE = 2;
/* Wait for select() to mark exception on socket. */
enum MYSQL_WAIT_EXCEPT = 4;
/*
  Wait until timeout occurs. Value of timeout can be obtained from
  mysql_get_timeout_value().
*/
enum MYSQL_WAIT_TIMEOUT = 8;

/*
  Set up and bring down the server; to ensure that applications will
  work when linked against either the standard client library or the
  embedded server library, these functions should be called.
*/
int mysql_server_init(int argc, char **argv, char **groups);
void mysql_server_end();

/*
  mysql_server_init/end need to be called when using libmysqld or
  libmysqlclient (exactly, mysql_server_init() is called by mysql_init() so
  you don't need to call it explicitely; but you need to call
  mysql_server_end() to free memory). The names are a bit misleading
  (mysql_SERVER* to be used when using libmysqlCLIENT). So we add more general
  names which suit well whether you're using libmysqld or libmysqlclient. We
  intend to promote these aliases over the mysql_server* ones.
*/

MYSQL_PARAMETERS *mysql_get_parameters();

/*
  Set up and bring down a thread; these function should be called
  for each thread in an application which opens at least one MySQL
  connection.  All uses of the connection(s) should be between these
  function calls.
*/
my_bool mysql_thread_init();
void mysql_thread_end();

/*
  Functions to get information from the MYSQL and MYSQL_RES structures
  Should definitely be used if one uses shared libraries.
*/

my_ulonglong mysql_num_rows(MYSQL_RES *res);
uint mysql_num_fields(MYSQL_RES *res);
my_bool mysql_eof(MYSQL_RES *res);
MYSQL_FIELD *mysql_fetch_field_direct(MYSQL_RES *res, uint fieldnr);
MYSQL_FIELD * mysql_fetch_fields(MYSQL_RES *res);
MYSQL_ROW_OFFSET mysql_row_tell(MYSQL_RES *res);
MYSQL_FIELD_OFFSET mysql_field_tell(MYSQL_RES *res);

uint mysql_field_count(MYSQL *mysql);
my_ulonglong mysql_affected_rows(MYSQL *mysql);
my_ulonglong mysql_insert_id(MYSQL *mysql);
uint mysql_errno(MYSQL *mysql);
char * mysql_error(MYSQL *mysql);
char *mysql_sqlstate(MYSQL *mysql);
uint mysql_warning_count(MYSQL *mysql);
char * mysql_info(MYSQL *mysql);
ulong mysql_thread_id(MYSQL *mysql);
char * mysql_character_set_name(MYSQL *mysql);
int   mysql_set_character_set(MYSQL *mysql, const(char)* csname);
int  mysql_set_character_set_start(int *ret, MYSQL *mysql, const(char)* csname);
int  mysql_set_character_set_cont(int *ret, MYSQL *mysql, int status);

MYSQL *		mysql_init(MYSQL *mysql);
my_bool		mysql_ssl_set(MYSQL *mysql, const char *key,
				      const(char)* cert, const(char)* ca,
				      const(char)*capath, const(char)* cipher);
char *    mysql_get_ssl_cipher(MYSQL *mysql);
my_bool		mysql_change_user(MYSQL *mysql, const(char)* user, 
					  const(char)*passwd, const(char)* db);
int mysql_change_user_start(my_bool *ret, MYSQL *mysql,
                                                const(char)* user,
                                                const(char)* passwd,
                                                const(char)* db);
int mysql_change_user_cont(my_bool *ret, MYSQL *mysql,
                                               int status);
MYSQL *		mysql_real_connect(MYSQL *mysql, const(char)* host,
					   const(char)* user,
					   const(char)* passwd,
					   const(char)* db,
					   uint port,
					   const(char)* unix_socket,
					   ulong clientflag);
int  mysql_real_connect_start(MYSQL **ret, MYSQL *mysql,
                                                 const(char)* host,
                                                 const(char)* user,
                                                 const(char)* passwd,
                                                 const(char)* db,
                                                 uint port,
                                                 const(char)* unix_socket,
                                                 ulong clientflag);
int mysql_real_connect_cont(MYSQL **ret, MYSQL *mysql, int status);
int mysql_select_db(MYSQL *mysql, const(char)* db);
int mysql_select_db_start(int *ret, MYSQL *mysql, const(char)* db);
int mysql_select_db_cont(int *ret, MYSQL *mysql, int status);
int mysql_query(MYSQL *mysql, const(char)* q);
int mysql_query_start(int *ret, MYSQL *mysql, const(char)* q);
int mysql_query_cont(int *ret, MYSQL *mysql, int status);
int mysql_send_query(MYSQL *mysql, const(char)* q, ulong length);
int mysql_send_query_start(int *ret, MYSQL *mysql, const(char)* q, ulong length);
int mysql_send_query_cont(int *ret, MYSQL *mysql, int status);
int mysql_real_query(MYSQL *mysql, const(char)* q, ulong length);
int mysql_real_query_start(int *ret, MYSQL *mysql, const(char)* q, ulong length);
int mysql_real_query_cont(int *ret, MYSQL *mysql, int status);
MYSQL_RES * mysql_store_result(MYSQL *mysql);
int             mysql_store_result_start(MYSQL_RES **ret, MYSQL *mysql);
int             mysql_store_result_cont(MYSQL_RES **ret, MYSQL *mysql, int status);
MYSQL_RES *     mysql_use_result(MYSQL *mysql);

void        mysql_get_character_set_info(MYSQL *mysql,
                           MY_CHARSET_INFO *charset);

/* local infile support */

enum LOCAL_INFILE_ERROR_LEN = 512;

void mysql_set_local_infile_handler(MYSQL *mysql,
         int function(void **,  char *, void *) local_infile_init,
         int function(void *, char *, uint) local_infile_read,
         void function(void *) local_infile_end,
         int function(void *, char*, uint) local_infile_error,
         void *);

void mysql_set_local_infile_default(MYSQL *mysql);

int mysql_shutdown(MYSQL *mysql, mysql_enum_shutdown_level shutdown_level);
int mysql_shutdown_start(int *ret, MYSQL *mysql, mysql_enum_shutdown_level shutdown_level);
int mysql_shutdown_cont(int *ret, MYSQL *mysql, int status);
int mysql_dump_debug_info(MYSQL *mysql);
int             mysql_dump_debug_info_start(int *ret, MYSQL *mysql);
int             mysql_dump_debug_info_cont(int *ret, MYSQL *mysql,
                                                   int status);
int mysql_refresh(MYSQL *mysql, uint refresh_options);
int mysql_refresh_start(int *ret, MYSQL *mysql, uint refresh_options);
int mysql_refresh_cont(int *ret, MYSQL *mysql, int status);
int mysql_kill(MYSQL *mysql,ulong pid);
int mysql_kill_start(int *ret, MYSQL *mysql, ulong pid);
int mysql_kill_cont(int *ret, MYSQL *mysql, int status);
int mysql_set_server_option(MYSQL *mysql, enum_mysql_set_option option);
int mysql_set_server_option_start(int *ret, MYSQL *mysql,
                                                      enum_mysql_set_option option);
int mysql_set_server_option_cont(int *ret, MYSQL *mysql, int status);
int		mysql_ping(MYSQL *mysql);
int             mysql_ping_start(int *ret, MYSQL *mysql);
int             mysql_ping_cont(int *ret, MYSQL *mysql, int status);
const char *	mysql_stat(MYSQL *mysql);
int             mysql_stat_start(const(char) **ret, MYSQL *mysql);
int             mysql_stat_cont(const(char) **ret, MYSQL *mysql, int status);
const char *	mysql_get_server_info(MYSQL *mysql);
const char *	mysql_get_server_name(MYSQL *mysql);
const char *	mysql_get_client_info();
ulong	mysql_get_client_version();
const char *	mysql_get_host_info(MYSQL *mysql);
ulong	mysql_get_server_version(MYSQL *mysql);
uint	mysql_get_proto_info(MYSQL *mysql);
MYSQL_RES *	mysql_list_dbs(MYSQL *mysql,const char *wild);
int             mysql_list_dbs_start(MYSQL_RES **ret, MYSQL *mysql,
                                             const(char)* wild);
int             mysql_list_dbs_cont(MYSQL_RES **ret, MYSQL *mysql,
                                            int status);
MYSQL_RES *	mysql_list_tables(MYSQL *mysql,const(char)* wild);
int             mysql_list_tables_start(MYSQL_RES **ret, MYSQL *mysql,
                                                const(char)* wild);
int             mysql_list_tables_cont(MYSQL_RES **ret, MYSQL *mysql,
                                               int status);
MYSQL_RES *	mysql_list_processes(MYSQL *mysql);
int             mysql_list_processes_start(MYSQL_RES **ret,
                                                   MYSQL *mysql);
int             mysql_list_processes_cont(MYSQL_RES **ret, MYSQL *mysql,
                                                  int status);
int		mysql_options(MYSQL *mysql,mysql_option option, void* arg);
void		mysql_free_result(MYSQL_RES *result);
int             mysql_free_result_start(MYSQL_RES *result);
int             mysql_free_result_cont(MYSQL_RES *result, int status);
void		mysql_data_seek(MYSQL_RES *result, my_ulonglong offset);
MYSQL_ROW_OFFSET mysql_row_seek(MYSQL_RES *result,
						MYSQL_ROW_OFFSET offset);
MYSQL_FIELD_OFFSET mysql_field_seek(MYSQL_RES *result,
					   MYSQL_FIELD_OFFSET offset);
MYSQL_ROW	mysql_fetch_row(MYSQL_RES *result);
int             mysql_fetch_row_start(MYSQL_ROW *ret,
                                              MYSQL_RES *result);
int             mysql_fetch_row_cont(MYSQL_ROW *ret, MYSQL_RES *result,
                                             int status);
ulong * mysql_fetch_lengths(MYSQL_RES *result);
MYSQL_FIELD *	mysql_fetch_field(MYSQL_RES *result);
MYSQL_RES *     mysql_list_fields(MYSQL *mysql, const(char)* table,
					  const char *wild);
int             mysql_list_fields_start(MYSQL_RES **ret, MYSQL *mysql,
                                                const(char)* table,
                                                const(char)* wild);
int             mysql_list_fields_cont(MYSQL_RES **ret, MYSQL *mysql,
                                               int status);
ulong	mysql_escape_string(char *to,const(char)* from, ulong from_length);
ulong	mysql_hex_string(char *to,const char *from, ulong from_length);
ulong mysql_real_escape_string(MYSQL *mysql, char *to,const(char)* from, ulong length);
void		mysql_debug(const(char)*);
void 		myodbc_remove_escape(MYSQL *mysql,char *name);
uint	mysql_thread_safe();
my_bool		mysql_embedded();
my_bool		mariadb_connection(MYSQL *mysql);
my_bool         mysql_read_query_result(MYSQL *mysql);
int             mysql_read_query_result_start(my_bool *ret,
                                                      MYSQL *mysql);
int             mysql_read_query_result_cont(my_bool *ret,
                                                     MYSQL *mysql, int status);


/*
  The following definitions are added for the enhanced 
  client-server protocol
*/

/* statement state */
enum enum_mysql_stmt_state
{
  MYSQL_STMT_INIT_DONE= 1, MYSQL_STMT_PREPARE_DONE, MYSQL_STMT_EXECUTE_DONE,
  MYSQL_STMT_FETCH_DONE
};


/*
  This structure is used to define bind information, and
  internally by the client library.
  Public members with their descriptions are listed below
  (conventionally `On input' refers to the binds given to
  mysql_stmt_bind_param, `On output' refers to the binds given
  to mysql_stmt_bind_result):

  buffer_type    - One of the MYSQL_* types, used to describe
                   the host language type of buffer.
                   On output: if column type is different from
                   buffer_type, column value is automatically converted
                   to buffer_type before it is stored in the buffer.
  buffer         - On input: points to the buffer with input data.
                   On output: points to the buffer capable to store
                   output data.
                   The type of memory pointed by buffer must correspond
                   to buffer_type. See the correspondence table in
                   the comment to mysql_stmt_bind_param.

  The two above members are mandatory for any kind of bind.

  buffer_length  - the length of the buffer. You don't have to set
                   it for any fixed length buffer: float, double,
                   int, etc. It must be set however for variable-length
                   types, such as BLOBs or STRINGs.

  length         - On input: in case when lengths of input values
                   are different for each execute, you can set this to
                   point at a variable containining value length. This
                   way the value length can be different in each execute.
                   If length is not NULL, buffer_length is not used.
                   Note, length can even point at buffer_length if
                   you keep bind structures around while fetching:
                   this way you can change buffer_length before
                   each execution, everything will work ok.
                   On output: if length is set, mysql_stmt_fetch will
                   write column length into it.

  is_null        - On input: points to a boolean variable that should
                   be set to TRUE for NULL values.
                   This member is useful only if your data may be
                   NULL in some but not all cases.
                   If your data is never NULL, is_null should be set to 0.
                   If your data is always NULL, set buffer_type
                   to MYSQL_TYPE_NULL, and is_null will not be used.

  is_unsigned    - On input: used to signify that values provided for one
                   of numeric types are unsigned.
                   On output describes signedness of the output buffer.
                   If, taking into account is_unsigned flag, column data
                   is out of range of the output buffer, data for this column
                   is regarded truncated. Note that this has no correspondence
                   to the sign of result set column, if you need to find it out
                   use mysql_stmt_result_metadata.
  error          - where to write a truncation error if it is present.
                   possible error value is:
                   0  no truncation
                   1  value is out of range or buffer is too small

  Please note that MYSQL_BIND also has internals members.
*/

struct st_mysql_bind
{
  ulong	*length;          /* output length pointer */
  my_bool       *is_null;	  /* Pointer to null indicator */
  void		*buffer;	  /* buffer to get/put data */
  /* set this if you want to track data truncations happened during fetch */
  my_bool       *error;
  ubyte *row_ptr;         /* for the current data position */
  void function(NET *net, st_mysql_bind *param) store_param_func;
  void function(st_mysql_bind *, MYSQL_FIELD *,
                       ubyte **row) fetch_result;
  void function(st_mysql_bind *, MYSQL_FIELD *,
                      ubyte **row) skip_result;
  /* output buffer length, must be set when fetching str/binary */
  ulong buffer_length;
  ulong offset;           /* offset position for char/binary fetch */
  ulong	length_value;     /* Used if length is 0 */
  uint	param_number;	  /* For null count and error messages */
  uint  pack_length;	  /* Internal length for packed data */
  enum_field_types buffer_type;	/* buffer type */
  my_bool       error_value;      /* used if error is 0 */
  my_bool       is_unsigned;      /* set if integer type is unsigned */
  my_bool	long_data_used;	  /* If used with mysql_send_long_data */
  my_bool	is_null_value;    /* Used if is_null is 0 */
  void *extension;
}
alias st_mysql_bind MYSQL_BIND;


struct st_mysql_stmt_extension;

/* statement handler */
struct st_mysql_stmt
{
  MEM_ROOT       mem_root;             /* root allocations */
  LIST           list;                 /* list to keep track of all stmts */
  MYSQL          *mysql;               /* connection handle */
  MYSQL_BIND     *params;              /* input parameters */
  MYSQL_BIND     *bind;                /* output parameters */
  MYSQL_FIELD    *fields;              /* result set metadata */
  MYSQL_DATA     result;               /* cached result set */
  MYSQL_ROWS     *data_cursor;         /* current row in cached result */
  /*
    mysql_stmt_fetch() calls this function to fetch one row (it's different
    for buffered, unbuffered and cursor fetch).
  */
  int function(st_mysql_stmt *stmt, ubyte** row) read_row_func;
  /* copy of mysql->affected_rows after statement execution */
  my_ulonglong   affected_rows;
  my_ulonglong   insert_id;            /* copy of mysql->insert_id */
  ulong	 stmt_id;	       /* Id for prepared statement */
  ulong  flags;                /* i.e. type of cursor to open */
  ulong  prefetch_rows;        /* number of rows per one COM_FETCH */
  /*
    Copied from mysql->server_status after execute/fetch to know
    server-side cursor status for this statement.
  */
  uint   server_status;
  uint	 last_errno;	       /* error code */
  uint   param_count;          /* input parameter count */
  uint   field_count;          /* number of columns in result set */
  enum_mysql_stmt_state state;    /* statement state */
  char		 last_error[MYSQL_ERRMSG_SIZE]; /* error message */
  char		 sqlstate[SQLSTATE_LENGTH+1];
  /* Types of input parameters should be sent to server */
  my_bool        send_types_to_server;
  my_bool        bind_param_done;      /* input buffers were supplied */
  ubyte  bind_result_done;     /* output buffers were supplied */
  /* mysql_stmt_close() had to cancel this result */
  my_bool       unbuffered_fetch_cancelled;  
  /*
    Is set to true if we need to calculate field->max_length for 
    metadata fields when doing mysql_stmt_store_result.
  */
  my_bool       update_max_length;     
  st_mysql_stmt_extension *extension;
}
alias st_mysql_stmt MYSQL_STMT;

enum enum_stmt_attr_type
{
  /*
    When doing mysql_stmt_store_result calculate max_length attribute
    of statement metadata. This is to be consistent with the old API, 
    where this was done automatically.
    In the new API we do that only by request because it slows down
    mysql_stmt_store_result sufficiently.
  */
  STMT_ATTR_UPDATE_MAX_LENGTH,
  /*
    ulong with combination of cursor flags (read only, for update,
    etc)
  */
  STMT_ATTR_CURSOR_TYPE,
  /*
    Amount of rows to retrieve from server per one fetch if using cursors.
    Accepts ulong attribute in the range 1 - ulong_max
  */
  STMT_ATTR_PREFETCH_ROWS
};

MYSQL_STMT * mysql_stmt_init(MYSQL *mysql);
int mysql_stmt_prepare(MYSQL_STMT *stmt, const char *query,
                               ulong length);
int mysql_stmt_prepare_start(int *ret, MYSQL_STMT *stmt,
                                     const char *query, ulong length);
int mysql_stmt_prepare_cont(int *ret, MYSQL_STMT *stmt, int status);
int mysql_stmt_execute(MYSQL_STMT *stmt);
int mysql_stmt_execute_start(int *ret, MYSQL_STMT *stmt);
int mysql_stmt_execute_cont(int *ret, MYSQL_STMT *stmt, int status);
int mysql_stmt_fetch(MYSQL_STMT *stmt);
int mysql_stmt_fetch_start(int *ret, MYSQL_STMT *stmt);
int mysql_stmt_fetch_cont(int *ret, MYSQL_STMT *stmt, int status);
int mysql_stmt_fetch_column(MYSQL_STMT *stmt, MYSQL_BIND *bind_arg, 
                                    uint column,
                                    ulong offset);
int mysql_stmt_store_result(MYSQL_STMT *stmt);
int mysql_stmt_store_result_start(int *ret, MYSQL_STMT *stmt);
int mysql_stmt_store_result_cont(int *ret, MYSQL_STMT *stmt,
                                         int status);
ulong mysql_stmt_param_count(MYSQL_STMT * stmt);
my_bool mysql_stmt_attr_set(MYSQL_STMT *stmt,
                                    enum_stmt_attr_type attr_type,
                                    const void *attr);
my_bool mysql_stmt_attr_get(MYSQL_STMT *stmt,
                                    enum_stmt_attr_type attr_type,
                                    void *attr);
my_bool mysql_stmt_bind_param(MYSQL_STMT * stmt, MYSQL_BIND * bnd);
my_bool mysql_stmt_bind_result(MYSQL_STMT * stmt, MYSQL_BIND * bnd);
my_bool mysql_stmt_close(MYSQL_STMT * stmt);
int mysql_stmt_close_start(my_bool *ret, MYSQL_STMT *stmt);
int mysql_stmt_close_cont(my_bool *ret, MYSQL_STMT * stmt, int status);
my_bool mysql_stmt_reset(MYSQL_STMT * stmt);
int mysql_stmt_reset_start(my_bool *ret, MYSQL_STMT * stmt);
int mysql_stmt_reset_cont(my_bool *ret, MYSQL_STMT *stmt, int status);
my_bool mysql_stmt_free_result(MYSQL_STMT *stmt);
int mysql_stmt_free_result_start(my_bool *ret, MYSQL_STMT *stmt);
int mysql_stmt_free_result_cont(my_bool *ret, MYSQL_STMT *stmt,
                                        int status);
my_bool mysql_stmt_send_long_data(MYSQL_STMT *stmt, 
                                          uint param_number,
                                          const char *data, 
                                          ulong length);
int mysql_stmt_send_long_data_start(my_bool *ret, MYSQL_STMT *stmt,
                                            uint param_number,
                                            const char *data,
                                            ulong len);
int mysql_stmt_send_long_data_cont(my_bool *ret, MYSQL_STMT *stmt,
                                           int status);
MYSQL_RES *mysql_stmt_result_metadata(MYSQL_STMT *stmt);
MYSQL_RES *mysql_stmt_param_metadata(MYSQL_STMT *stmt);
uint mysql_stmt_errno(MYSQL_STMT * stmt);
char *mysql_stmt_error(MYSQL_STMT * stmt);
char *mysql_stmt_sqlstate(MYSQL_STMT * stmt);
MYSQL_ROW_OFFSET mysql_stmt_row_seek(MYSQL_STMT *stmt, 
                                             MYSQL_ROW_OFFSET offset);
MYSQL_ROW_OFFSET mysql_stmt_row_tell(MYSQL_STMT *stmt);
void mysql_stmt_data_seek(MYSQL_STMT *stmt, my_ulonglong offset);
my_ulonglong mysql_stmt_num_rows(MYSQL_STMT *stmt);
my_ulonglong mysql_stmt_affected_rows(MYSQL_STMT *stmt);
my_ulonglong mysql_stmt_insert_id(MYSQL_STMT *stmt);
uint mysql_stmt_field_count(MYSQL_STMT *stmt);

my_bool mysql_commit(MYSQL * mysql);
int mysql_commit_start(my_bool *ret, MYSQL * mysql);
int mysql_commit_cont(my_bool *ret, MYSQL * mysql, int status);
my_bool mysql_rollback(MYSQL * mysql);
int mysql_rollback_start(my_bool *ret, MYSQL * mysql);
int mysql_rollback_cont(my_bool *ret, MYSQL * mysql, int status);
my_bool mysql_autocommit(MYSQL * mysql, my_bool auto_mode);
int mysql_autocommit_start(my_bool *ret, MYSQL * mysql,
                                   my_bool auto_mode);
int mysql_autocommit_cont(my_bool *ret, MYSQL * mysql, int status);
my_bool mysql_more_results(MYSQL *mysql);
int mysql_next_result(MYSQL *mysql);
int mysql_next_result_start(int *ret, MYSQL *mysql);
int mysql_next_result_cont(int *ret, MYSQL *mysql, int status);
int mysql_stmt_next_result(MYSQL_STMT *stmt);
int mysql_stmt_next_result_start(int *ret, MYSQL_STMT *stmt);
int mysql_stmt_next_result_cont(int *ret, MYSQL_STMT *stmt, int status);
void mysql_close_slow_part(MYSQL *mysql);
void mysql_close(MYSQL *sock);
int mysql_close_start(MYSQL *sock);
int mysql_close_cont(MYSQL *sock, int status);
my_socket mysql_get_socket(const MYSQL *mysql);
uint mysql_get_timeout_value(const MYSQL *mysql);
uint mysql_get_timeout_value_ms(const MYSQL *mysql);

/* status return codes */
enum MYSQL_NO_DATA =        100;
enum MYSQL_DATA_TRUNCATED = 101;

