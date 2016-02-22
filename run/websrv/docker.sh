# run websrv docker linked to other
docker ps | grep ${W2L_INSTANCE_NAME}-websrv &> /dev/null
if [[ $? -ne 0 ]] ; then
 docker ps -a | grep ${W2L_INSTANCE_NAME}-websrv &> /dev/null
 if [[ $? -eq 0 ]] ; then
  docker start ${W2L_INSTANCE_NAME}-websrv
 else
  EXT_UID=$(id -u)
  EXT_GID=$(id -g)
  if [[ "$EXT_UID" == "0" ]] ; then
   EXT_UID=1000
  fi
  if [[ "$EXT_GID" == "0" ]] ; then
   EXT_GID=1000
  fi

  CERTS_MOUNT=""
  if [[ -d certs/ ]] ; then
   CERTS_MOUNT=" -v "$(pwd)"/certs/:/certs/:ro "
  fi

  docker run -ti $MORE_ARGS --hostname websrv.$W2L_DOMAIN_NAME \
   $CERTS_MOUNT \
   -e USER_UID=$EXT_UID \
   -e USER_GID=$EXT_GID \
   -v $(readlink -f $(dirname $(readlink -f $0))"/.."):/var/www/WikiToLearn/ --name ${W2L_INSTANCE_NAME}-websrv \
   --link ${W2L_INSTANCE_NAME}-mysql:mysql \
   --link ${W2L_INSTANCE_NAME}-memcached:memcached \
   --link ${W2L_INSTANCE_NAME}-ocg:ocg \
   -d $W2L_DOCKER_WEBSRV

  if [[ "$W2L_RELAY_HOST" != "" ]] ; then
   {
    docker exec ${W2L_INSTANCE_NAME}-websrv sed '/^mailhub/d' /etc/ssmtp/ssmtp.conf
    echo "mailhub=${W2L_RELAY_HOST}" | docker exec -i ${W2L_INSTANCE_NAME}-websrv tee -a /etc/ssmtp/ssmtp.conf
   } &> /dev/null
  fi
 fi
fi

REF_W2L_WEBSRV="docker:${W2L_INSTANCE_NAME}-websrv"
