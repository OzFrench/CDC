/*
 * Set's a users password from the command line
 *
 * To compile, run
 *
 * $ cc -o setpwd setpwd.c -ls
 *
 *
 * History
 *
 *   6 Oct 93      Overwrite the argv[] entries for passwords to stop
 *                  'ps' snoopers
 *   7 Oct 93      Add call to set the seed
 */
#include <stdio.h>
#include <userpw.h>
#include <usersec.h>
#include <errno.h>
#include <pwd.h>
#include <string.h>
#include <stdlib.h>

/*
 * Variables required by getopt
 */
extern int optind;
/*
extern char optopt;
*/
extern int opterr;
extern char *optarg;
int    getopt(int argc, char **argv, char *option);

/*
 * Encryption algorithm declarations
 */
extern char *crypt(char *,char *);

/*
 * Possible characters for the salt
 */
#define SALT "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXRZ0123456789"
#define SALT_LENGTH (2)

/*
 * ETC_PASSWD_FILE is the actual password database
 */
#define ETC_PASSWD_FILE      "/etc/passwd"

/*
 * Choose a random character from a string
 */
static char random_char(char *ch_list)
{
  int no_of_chars;
  int index;
  no_of_chars = strlen(ch_list);
  index = rand()%no_of_chars;
  return ch_list[index];
}

/*
 * Generate a salt of SALT_LENGTH characters returned as a null
terminated
 * string.  The return code is overwritten on each call so save if
required
 */
char *generate_salt()
{
  int loop;
  static char salt[SALT_LENGTH+1];
  for (loop = 0 ; loop < SALT_LENGTH ; loop++)
  {
    salt[loop] = random_char(SALT);
  }
  salt[SALT_LENGTH]='\0';
  return salt;
}

/*
 * Initialise the random number generated based on the current time as
 * a seed
 */
void initialise_generate_password()
{
  time_t ltime;
  time(&ltime);
  srand(ltime);
}

/*
 * Encrypt a password using the salt.
 */
char *encrypt_password(password, salt)
char *password;
char *salt;
{
  char *pwd;

  pwd=crypt(password,salt);
  return pwd;
}

/*
 * Print a usage message and exit
 */
void usage()
{
  fprintf(stderr,"setpwd: Usage setpwd -u userid -p password [-a][-e]\n");
  fprintf(stderr,"                     -a     User not prompted for new password on first login\n");
  fprintf(stderr,"                            If password is -, password read from stdin\n");
  fprintf(stderr,"                     -e     Password already encypted\n");
  exit(1);
}

/*
 * Set the users password
 */
int main(int argc, char **argv)
{
  int arg;
  char *user=NULL;
  char *password=NULL;
  struct userpw newpw;
  struct userpw *oldpw;
  char   *salt;
  char   *pwd;
  struct passwd *etcpasswd;
  FILE   *passwdfp;
  char   buffer[BUFSIZ];
  int    noadmchg=FALSE; /* Force user to change when logs in */
  int    pwdencrypt=TRUE;
  char  *etc_passwd_entry="!";

  initialise_generate_password(); /* Set the seed */

  while (arg!=EOF)
  {
    arg=getopt(argc, argv, "u:p:ae");
    switch(arg)
    {
    default:
    case '?':
      usage();
      break;
    case 'u':
      user=strdup(optarg); /* Set the user */
      memset(argv[optind-1],'\0',strlen(argv[optind-1]));
      break;
    case 'p':
      password=optarg;  /* Set the password text */
      if (strcmp(password,"-")==0) /* Password from stdin ? */
      {
 fgets(buffer,sizeof(buffer)-1,stdin);
 if (strlen(buffer)!=0)
   buffer[strlen(buffer)-1]='\0';
 password=buffer;
      }
      else
      {
 password=strdup(password);
 memset(argv[optind-1],'\0',strlen(argv[optind-1]));
      }
      break;
    case 'a':
      noadmchg=TRUE;
      break;
    case 'e':
      pwdencrypt=FALSE;
      break;
    case EOF:
      break;
    }
  }

  if (user==NULL && password==NULL)
    usage();

  /*
   * Check that both a user and a password are supplied
   */
  if (user==NULL)
  {
    fprintf(stderr,"setpwd: you must supply a user id using the -u parameter\n");
    exit(2);
  }
  if (password==NULL)
  {
    fprintf(stderr,"setpwd: you must supply a password using the -p parameter\n");
    exit(3);
  }

  /*
   * Now create the entry to update the password.  An empty password
   * encrypts to the empty string.
   */
  if (!pwdencrypt)
  {
    etc_passwd_entry=pwd=password;
  }
  else if (*password!='\0')
  {
    salt=generate_salt();
    pwd=encrypt_password(password,salt); /* Encrypted password */
  }
  else
  {
    pwd="";
  }
  strcpy(newpw.upw_name,user);
  newpw.upw_passwd=pwd;
  time(&newpw.upw_lastupdate); /* Update time */
  if (noadmchg)
    newpw.upw_flags=0;
  else
    newpw.upw_flags=PW_ADMCHG; /* Force user to change when next login
*/
  if (putuserpw(&newpw)!=0) /* Enter the password */
  {
    perror("putuserpw");
    fprintf(stderr,"setpwd: cannot set password information for %s\n",
user);
    exit(errno);
  }

  /*
   * For a new user, the password entry in /etc/passwd is set to '*'
   * This means password not set.  This must be changed to a '!' to
   * mean 'look in /etc/security/passwd'
   */
  if (setuserdb (S_WRITE))
  {
    perror("setuserdb");
    fprintf(stderr,"setpwd: cannot open password database for writing\n");
    exit(errno);
  }

  if (putuserattr (newpw.upw_name, S_PWD, etc_passwd_entry, SEC_CHAR))
  {
    perror("putuserattr");
    fprintf(stderr,"setpwd: cannot change password entry to %s\n",etc_passwd_entry);
    exit(errno);
  }

  if (putuserattr (newpw.upw_name, NULL, NULL, SEC_COMMIT))
  {
    perror("putuserattr");
    fprintf(stderr,"setpwd: cannot commit changed to password database\n");
    exit(errno);
  }

  if (enduserdb())
  {
    perror("enduserdb");
    fprintf(stderr,"setpwd: cannot close password database\n");
    exit(errno);
  } return 0;   /* All o.k. */
}

