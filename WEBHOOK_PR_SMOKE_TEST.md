# PR 웹훅 수신 점검

이 문서는 GitHub pull request 이벤트가 Slack 웹훅으로 전달되는지 확인하기 위한 무해한 점검용 변경입니다.

- 생성 목적: `pull_request.opened` 이벤트 수신 확인
- 인프라 영향: 없음
- 검증 기준: PR 생성 뒤 Slack 스레드에 웹훅 응답이 도착하는지 확인
