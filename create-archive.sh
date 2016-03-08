#!/bin/bash
cd $(dirname $(realpath $0))
if [[ ! -f "$0" ]] ; then
 echo "Error changing directory"
 exit 1
fi

. ./load-wikitolearn.sh

if [[ -d "$WTL_REPO_DIR" ]] ; then
 cd "$WTL_REPO_DIR"
else
 echo "Missing the '$WTL_REPO_DIR' directory"
 exit 1
fi

git update-index -q --refresh
if [[ $(git diff-index --name-only HEAD -- | wc -l) -gt 0 ]] ; then
 echo "You have to commit/rollback all changes before this"
 exit 1
fi
if [[ $(git status --porcelain | wc -l) -gt 0 ]] ; then
 echo "You have to commit/rollback all changes before this"
 exit 1
fi

if [[ $# -lt 2 ]] ; then
 echo "Missing arguments"
 echo "You have to run $0 -t <tag> or $0 -c <commit>"
 exit 1
fi

while [[ $# > 1 ]] ; do
  case $1 in
    -c|--commit)
      export REFERENCE="$2"
      shift
    ;;
    -t|--tag)
      export REFERENCE="$2"
      shift
    ;;
    *)
      echo "Unknow option $1"
      exit 1
    ;;
  esac
  shift
done

echo "Searching for commit for "${REFERENCE}

git show ${REFERENCE} &> /dev/null
if [[ $? -ne 0 ]] ; then
 echo "The "${REFERENCE}" is not an uniq id for a commit"
 exit 1
fi

echo "Found!"

git show ${REFERENCE}

if [[ -f ${WTL_ARCHIVES}"/"${REFERENCE}.tar ]] ; then
 echo "File "${WTL_ARCHIVES}"/"${REFERENCE}".tar exist"
else
 rsync -a --stats --delete ${WTL_REPO_DIR}"/" ${WTL_ARCHIVES}"/"${REFERENCE}
 cd ${WTL_ARCHIVES}"/"${REFERENCE}
 if [[ $? -ne 0 ]] ; then
  echo "Error in the change directory operation"
  exit 1
 else
  echo "New location"

  git checkout ${REFERENCE}
  git submodule update --init --checkout --recursive

  rm -Rf .git
  find -name .git -delete

  cd ${WTL_ARCHIVES}

  tar -cvf ${REFERENCE}.tar ${REFERENCE}
  if [[ $? -eq 0 ]] ; then
   cd $(dirname $(realpath $0))

   rm -Rf ${WTL_ARCHIVES}"/"${REFERENCE}
  fi
 fi
fi
