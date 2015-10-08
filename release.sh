source .secrets
[[ -z "$KEY" ]] && { echo "KEY is unset"; exit 1; }
[[ -z "$RELEASE_VERSION" ]] && { echo "RELEASE_VERSION is unset"; exit 1; }
[[ -z "$NEXT_VERSION" ]] && { echo "NEXT_VERSION is unset"; exit 1; }
git checkout -b release-$RELEASE_VERSION || exit 1
mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=${RELEASE_VERSION} || exit 1
git add . || exit 1
git commit -m"Prepare for release ${RELEASE_VERSION}" || exit 1
mvn clean package || exit 1
curl -uphilwebb:${KEY} -X PUT -T "./org.springframework.ide.eclipse.jdt.formatter.site/target/org.springframework.ide.eclipse.jdt.formatter.site.zip" \
  https://api.bintray.com/content/philwebb/spring-eclipse-code-formatter/spring-eclipse-code-formatter/${RELEASE_VERSION}/${RELEASE_VERSION}/site.zip?explode\=1\&publish\=1 || exit 1
git tag v${RELEASE_VERSION} || exit 1
git push philwebb v${RELEASE_VERSION} || exit 1
git checkout master
mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=${NEXT_VERSION} || exit 1
git add . || exit 1
git commit -m"Set development version to ${NEXT_VERSION}" || exit 1
git push philwebb master || exit 1
