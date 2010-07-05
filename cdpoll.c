#include <stdio.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/cdrom.h>

/* Error codes:
 * 0 = success, red book audio or multisession CD with audio
 * 1 = bad arguments, IOCTL errors
 * 2 = drive not ready, tray open, no disc
 * 3 = disc present, but is data, not audio
 **/
int main(int argc, char **argv)
{
  int cdfd = -1;
  int ret;
  int status = 2; /* Error */

  if(argc < 2) {
    fprintf(stderr, "ERROR: You idiot.\n");
    return 1;
  }
  
  if((cdfd = open(argv[1], O_RDONLY | O_NONBLOCK)) < 0) {
    fprintf(stderr, "Error opening CD-ROM device %s!\n", argv[1]);
    return 1;
  }
  
  if((ret = ioctl(cdfd, CDROM_DRIVE_STATUS, 0)) < 0) {
    return 1;
  } else {
    switch(ret) {
    case CDS_NO_DISC:
    case CDS_TRAY_OPEN:
    case CDS_DRIVE_NOT_READY:
      status = 2;
      break;
      
    case CDS_DISC_OK: {
      int type = ioctl(cdfd, CDROM_DISC_STATUS, 0);

      if(type < 0) {
	fprintf(stderr, "CDROM_DISC_STATUS error: %d\n", type);
	return 1;
      }

      switch(type) {
      case CDS_AUDIO:
      case CDS_MIXED:
	status = 0;
	break;

      default:
	status = 3;
      }
    }
    }
  }
  close(cdfd);

  return status;  
}
