<script setup lang="ts">
import { useTheme } from 'vuetify'
import { getMessaging, onMessage } from 'firebase/messaging'
import ScrollToTop from '@base/@core/components/ScrollToTop.vue'
import initCore from '@base/@core/initCore'
import { initConfigStore, useConfigStore } from '@base/@core/stores/config'
import { hexToRgb } from '@base/@core/utils/colorConverter'

// ℹ️ Sync current theme with initial loader theme
initCore()
initConfigStore()

const configStore = useConfigStore()

const { isMobile } = useDevice()
const { global } = useTheme()

if (isMobile)
  configStore.appContentLayoutNav = 'vertical'

const notificationStore = useMessageStore()

onBeforeMount(async () => {
  onMessage(getMessaging(), () => {
    // TODO: Handle incoming messages
    // console.log('Client message:', payload)
    // const linkSplits = payload.fcmOptions?.link?.split('/projects/')
    // notify(payload.notification?.body as string, { type: 'primary', link: `/projects/${linkSplits![1]}` })
  })
})
</script>

<template>
  <VLocaleProvider :rtl="configStore.isAppRTL">
    <!-- ℹ️ This is required to set the background color of active nav link based on currently active global theme's primary -->
    <VApp :style="`--v-global-theme-primary: ${hexToRgb(global.current.value.colors.primary)}`">
      <NuxtLoadingIndicator />
      <NuxtLayout>
        <NuxtPage />
      </NuxtLayout>

      <ScrollToTop />

      <ConfirmDialog
        :model-value="Boolean(notificationStore.confirmationMessage)"
        :message="notificationStore.confirmationMessage"
        @confirm="notificationStore.resolveConfirmation"
      />
    </VApp>
  </VLocaleProvider>
</template>
