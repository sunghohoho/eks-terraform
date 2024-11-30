# https://plugins.jenkins.io/keycloak/
# 필요 목록
# 렐름
# 클라이언트 - redirect url (https://jenkins-test.gguduck.com/), 클라이언트 credentials (client secret)
# 젠킨스 플러그인 생성 keycloak auth
# security에서 Security Realm 추가, 
# {
#   "realm": "myrealm",
#   "auth-server-url": "https://sso.gguduck.com/",
#   "ssl-required": "external",
#   "resource": "jenkins",
#   "public-client": false,
#   "credentials": {
#     "secret": "client secret-key"
#   }
# }


